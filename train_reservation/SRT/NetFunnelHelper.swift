
import Foundation
import RegexBuilder

// NetFunnel 관련 에러를 정의하기 위한 열거형
enum NetFunnelError: Error, LocalizedError {
    case failedToComplete(String)
    case failedToParseResponse(String)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .failedToComplete(let message):
            return "넷퍼넬 처리를 완료하지 못했습니다: \(message)"
        case .failedToParseResponse(let message):
            return "넷퍼넬 응답을 파싱하는데 실패했습니다: \(message)"
        case .invalidURL:
            return "잘못된 URL입니다."
        }
    }
}

class NetFunnelHelper {
    // MARK: - Properties
    
    private let session: URLSession
    private var cachedKey: String?
    private var lastFetchTime: TimeInterval = 0
    private let cacheTTL: TimeInterval = 48 // 48초
    private let debug: Bool

    // MARK: - Initializer
    
    init(debug: Bool = false) {
        self.debug = debug
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SRTConstant.NetFunnel.DEFAULT_HEADERS
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods
    
    /// 넷퍼넬 프로세스를 실행하고 인증 키를 반환합니다.
    func run() async throws -> String {
        let currentTime = Date().timeIntervalSince1970
        if isCacheValid(currentTime: currentTime), let cachedKey = self.cachedKey {
            return cachedKey
        }

        do {
            var (status, key, nwait, ip) = try await start()
            self.cachedKey = key
            self.lastFetchTime = currentTime

            // pass status까지 계속 check
            while status == SRTConstant.NetFunnel.WAIT_STATUS_FAIL {
//                if debug {
                print("\r현재 \(nwait ?? 0)명 대기중...", terminator: "")
//                }
                try await Task.sleep(for: .seconds(1))
                (status, self.cachedKey, nwait, ip) = try await check(ip: ip)
            }
            
            // NetFunnel 완료
            let (completeStatus, _, _, _) = try await complete(ip: ip)
            if completeStatus == SRTConstant.NetFunnel.WAIT_STATUS_PASS || completeStatus == SRTConstant.NetFunnel.ALREADY_COMPLETED {
                if let finalKey = self.cachedKey {
                    return finalKey
                }
            }

            clear()
            throw NetFunnelError.failedToComplete("최종 키 획득 실패")

        } catch {
            clear()
            throw error // 발생한 에러를 다시 던짐
        }
    }

    /// 캐시된 키와 마지막 요청 시간을 초기화합니다.
    func clear() {
        cachedKey = nil
        lastFetchTime = 0
    }

    // MARK: - Private Methods
    
    private func start() async throws -> (String, String?, Int?, String?) {
        return try await makeRequest(opcodeKey: "getTidchkEnter")
    }

    private func check(ip: String?) async throws -> (String, String?, Int?, String?) {
        return try await makeRequest(opcodeKey: "chkEnter", ip: ip)
    }

    private func complete(ip: String?) async throws -> (String, String?, Int?, String?) {
        return try await makeRequest(opcodeKey: "setComplete", ip: ip)
    }

    /// 실제 네트워크 요청을 생성하고 실행합니다.
    private func makeRequest(opcodeKey: String, ip: String? = nil) async throws -> (String, String?, Int?, String?) {
        let baseUrl = ip ?? "nf.letskorail.com"
        guard var components = URLComponents(string: "https://\(baseUrl)/ts.wseq") else {
            throw NetFunnelError.invalidURL
        }
        
        guard let opcode = SRTConstant.NetFunnel.OP_CODE[opcodeKey] else {
            throw NetFunnelError.failedToComplete("유효하지 않은 OpCode 키: \(opcodeKey)")
        }

        components.queryItems = buildParams(opcode: opcode)

        guard let url = components.url else {
            throw NetFunnelError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        let responseString = String(data: data, encoding: .utf8) ?? ""

//        if debug {
        print(responseString)
        print("====================================")
//        }

        let parsed = try parse(response: responseString)
        
        guard let status = parsed["status"] else {
            throw NetFunnelError.failedToParseResponse("상태(status) 값을 찾을 수 없음")
        }
        
        let key = parsed["key"]
        let nwait = Int(parsed["nwait"] ?? "")
        let responseIp = parsed["ip"]

        return (status, key, nwait, responseIp)
    }

    /// 요청에 필요한 파라미터를 생성합니다.
    private func buildParams(opcode: String, key: String? = nil) -> [URLQueryItem] {
        var params: [String: String?] = [
            "opcode": opcode,
            "nfid": "0",
            "prefix": "NetFunnel.gRtype=\(opcode);",
            "js": "true",
            String(Int(Date().timeIntervalSince1970 * 1000)): "",
        ]

        if opcode == SRTConstant.NetFunnel.OP_CODE["getTidchkEnter"] || opcode == SRTConstant.NetFunnel.OP_CODE["chkEnter"] {
            params["sid"] = "service_1"
            params["aid"] = "act_10"
            if opcode == SRTConstant.NetFunnel.OP_CODE["chkEnter"] {
//                params["key"] = key ?? self.cachedKey
                if key == nil {
                    params["key"] = self.cachedKey
                } else {
                    params["key"] = key
                }
                params["ttl"] = "1"
            }
        } else if opcode == SRTConstant.NetFunnel.OP_CODE["setComplete"] {
//            params["key"] = key ?? self.cachedKey
            if key == nil {
                params["key"] = self.cachedKey
            } else {
                params["key"] = key
            }
        }

        return params.map { URLQueryItem(name: $0.key, value: $0.value) }
    }

    /// 자바스크립트 형태의 응답 문자열을 파싱합니다.
    private func parse(response: String) throws -> [String: String] {
        let regex = #/NetFunnel\.gControl\.result='([^']+)'/#
        guard let resultMatch = response.firstMatch(of: regex) else {
            throw NetFunnelError.failedToParseResponse("응답에서 result 값을 찾을 수 없음")
        }

        let parts = String(resultMatch.1).split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        guard parts.count == 3 else {
            throw NetFunnelError.failedToParseResponse("응답 형식이 유효하지 않음 (부분이 3개가 아님)")
        }

        let code = String(parts[0])
        let status = String(parts[1])
        let paramsStr = String(parts[2])

        var params = paramsStr.split(separator: "&")
            .filter { $0.contains("=") }
            .reduce(into: [String: String]()) { dict, param in
                let keyValue = param.split(separator: "=", maxSplits: 1)
                if keyValue.count == 2 {
                    dict[String(keyValue[0])] = String(keyValue[1])
                }
            }
        
        params["code"] = code
        params["status"] = status
        
        return params
    }

    /// 로컬 캐시가 유효한지 확인합니다.
    private func isCacheValid(currentTime: TimeInterval) -> Bool {
        guard cachedKey != nil else { return false }
        return (currentTime - lastFetchTime) < cacheTTL
    }
}
