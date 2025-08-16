//
//  SRTAPIClient.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import Foundation

// SRT 열차 정보를 담을 구조체 (srt.py의 SRTTrain 클래스 참고)
struct SRTTrain: Codable, Identifiable {
    let id = UUID() // SwiftUI List에서 Identifiable을 위해 필요
    let trainCode: String
    let trainName: String
    let trainNumber: String
    
    let depDate: String
    let depTime: String
    let depStationCode: String
    let depStationName: String
    
    let arrDate: String
    let arrTime: String
    let arrStationCode: String
    let arrStationName: String
    
    let generalSeatState: String // 일반실 좌석 상태 (예: "예약가능", "매진")
    let specialSeatState: String // 특실 좌석 상태
    
    // Codable 키 매핑 (JSON 키와 Swift 속성 이름이 다를 경우)
    enum CodingKeys: String, CodingKey {
        case trainCode = "stlbTrnClsfCd"
        case trainName = "stlbTrnClsfCdNm" // srt.py에서는 TRAIN_NAME 딕셔너리 사용
        case trainNumber = "trnNo"
        
        case depDate = "dptDt"
        case depTime = "dptTm"
        case depStationCode = "dptRsStnCd"
        case depStationName = "dptRsStnCdNm"
        
        case arrDate = "arvDt"
        case arrTime = "arvTm"
        case arrStationCode = "arvRsStnCd"
        case arrStationName = "arvRsStnCdNm"
        
        case generalSeatState = "gnrmRsvPsbStr"
        case specialSeatState = "sprmRsvPsbStr"
    }
    
    // 편의를 위한 초기화 (JSON 파싱 시 사용)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trainCode = try container.decode(String.self, forKey: .trainCode)
        trainName = try container.decode(String.self, forKey: .trainName)
        trainNumber = try container.decode(String.self, forKey: .trainNumber)
        
        depDate = try container.decode(String.self, forKey: .depDate)
        depTime = try container.decode(String.self, forKey: .depTime)
        depStationCode = try container.decode(String.self, forKey: .depStationCode)
        depStationName = try container.decode(String.self, forKey: .depStationName)
        
        arrDate = try container.decode(String.self, forKey: .arrDate)
        arrTime = try container.decode(String.self, forKey: .arrTime)
        arrStationCode = try container.decode(String.self, forKey: .arrStationCode)
        arrStationName = try container.decode(String.self, forKey: .arrStationName)
        
        generalSeatState = try container.decode(String.self, forKey: .generalSeatState)
        specialSeatState = try container.decode(String.self, forKey: .specialSeatState)
    }
}

// SRT API 응답 데이터 구조 (srt.py의 SRTResponseData 참고)
struct SRTResponseDataSet: Codable {
    let dsOutput1: [SRTTrain]
    // 다른 dsOutputX가 있다면 여기에 추가
    
    enum CodingKeys: String, CodingKey {
        case dsOutput1 = "dsOutput1"
    }
}

// SRT API 호출을 담당하는 클라이언트
class SRTAPIClient: ObservableObject {
    // 로그인 상태를 외부에 알리기 위해 ObservableObject 사용
    @Published var isLoggedIn = false
    
    // 로그인 요청
    func login(id: String, password: String) async -> Bool {
        // srt.py의 getLoginType 함수 로직을 그대로 사용
        func getLoginType(for id: String) -> String {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let phoneRegex = "^01(?:0|1|[6-9])-(?:\\d{3}|\\d{4})-\\d{4}$"
            
            if id.range(of: emailRegex, options: .regularExpression) != nil {
                return "2" // 이메일
            } else if id.range(of: phoneRegex, options: .regularExpression) != nil {
                return "3" // 전화번호
            } else {
                return "1" // 회원번호
            }
        }
        
        var processedId = id
        if getLoginType(for: id) == "3" {
            processedId = id.replacingOccurrences(of: "-", with: "")
        }
        
        guard let url = URL(string: SRTConstant.API_ENDPOINTS["login"]!)
 else { return false }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "auto", value: "Y"),
            URLQueryItem(name: "check", value: "Y"),
            URLQueryItem(name: "page", value: "menu"),
            URLQueryItem(name: "deviceKey", value: "-"),
            URLQueryItem(name: "customerYn", value: ""),
            URLQueryItem(name: "login_referer", value: SRTConstant.API_ENDPOINTS["main"]!),
            URLQueryItem(name: "srchDvCd", value: getLoginType(for: id)),
            URLQueryItem(name: "srchDvNm", value: processedId),
            URLQueryItem(name: "hmpgPwdCphd", value: password)
        ]
        
        guard let httpBody = components.query?.data(using: .utf8) else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(SRTConstant.USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue(SRTConstant.DEFAULT_HEADERS["Accept"], forHTTPHeaderField: "Accept")
        
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return false }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("SRT Login Response: \(responseString)")
                if responseString.contains("userMap") {
                    self.isLoggedIn = true
                    return true
                }
            }
        } catch {
            print("Login network error: \(error.localizedDescription)")
        }
        return false
    }
    
    // 열차 조회 요청
    func searchTrain(
        departureStationCode: String,
        arrivalStationCode: String,
        date: String,
        time: String,
        passengerCount: Int,
        netfunnelKey: String? // 넷퍼넬 키 파라미터 추가
    ) async -> [SRTTrain]? {
        guard self.isLoggedIn else { return nil } // 로그인 상태가 아니면 조회 불가
        
        guard let url = URL(string: SRTConstant.API_ENDPOINTS["search_schedule"]!)
 else { return nil }
        
        // 요청 바디 데이터 구성 (srt.py의 search_train data 파라미터 참고)
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "chtnDvCd", value: "1"),
            URLQueryItem(name: "dptDt", value: date),
            URLQueryItem(name: "dptTm", value: time),
            URLQueryItem(name: "dptDt1", value: date),
            URLQueryItem(name: "dptTm1", value: time.prefix(2) + "0000"),
            URLQueryItem(name: "dptRsStnCd", value: departureStationCode),
            URLQueryItem(name: "arvRsStnCd", value: arrivalStationCode),
            URLQueryItem(name: "stlbTrnClsfCd", value: "05"), // 05: 전체 열차
            URLQueryItem(name: "trnGpCd", value: "109"),
            URLQueryItem(name: "trnNo", value: ""),
            URLQueryItem(name: "psgNum", value: String(passengerCount)),
            URLQueryItem(name: "seatAttCd", value: "015"),
            URLQueryItem(name: "arriveTime", value: "N"),
            URLQueryItem(name: "tkDptDt", value: ""),
            URLQueryItem(name: "tkDptTm", value: ""),
            URLQueryItem(name: "tkTrnNo", value: ""),
            URLQueryItem(name: "tkTripChgFlg", value: ""),
            URLQueryItem(name: "dlayTnumAplFlg", value: "Y"),
            URLQueryItem(name: "netfunnelKey", value: netfunnelKey ?? ""), // 전달받은 키 사용, 없으면 빈 문자열
        ]
        
        guard let httpBody = components.query?.data(using: .utf8) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(SRTConstant.USER_AGENT, forHTTPHeaderField: "User-Agent")
        request.setValue(SRTConstant.DEFAULT_HEADERS["Accept"], forHTTPHeaderField: "Accept")
        
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("SRT Train Search Response: \(responseString)") // 응답 전체 출력
            }
            
            // 응답 JSON 파싱
            let decoder = JSONDecoder()
            let json = try decoder.decode([String: SRTResponseDataSet].self, from: data)
            
            if let output1 = json["outDataSets"]?.dsOutput1 {
                // SRT 열차만 필터링 (stlbTrnClsfCd == "17")
                let srtTrains = output1.filter { $0.trainCode == "17" }
                return srtTrains
            }
            
        } catch {
            print("Train search network or parsing error: \(error.localizedDescription)")
        }
        return nil
    }
}
