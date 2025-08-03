//
//  SRTView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// SRT 로그인 및 예매 화면을 위한 View
struct SRTView: View {
    // 사용자 아이디와 비밀번호를 저장하는 상태 변수
    @State private var id = ""
    @State private var password = ""
    
    // 로그인 진행 상태를 나타내는 변수
    @State private var isLoading = false
    
    // 알림창 표시 여부 및 메시지
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        // Form은 설정이나 데이터 입력에 적합한 UI를 제공
        Form {
            Section(header: Text("SRT 로그인 정보")) {
                TextField("아이디 (회원번호, 이메일, 전화번호)", text: $id)
                    .keyboardType(.emailAddress) // 이메일 키보드 타입
                    .autocapitalization(.none) // 자동 대문자화 방지
                
                SecureField("비밀번호", text: $password)
                    .keyboardType(.default)
            }
            
            Section {
                Button("로그인") {
                    // 로그인 버튼 클릭 시 비동기 작업 시작
                    Task {
                        await loginSRT()
                    }
                }
                .disabled(isLoading) // 로그인 중에는 버튼 비활성화
            }
        }
        .navigationTitle("SRT 로그인") // 네비게이션 바 제목
        .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
        // View가 화면에 나타날 때 실행되는 코드
        .onAppear {
            // 키체인에서 저장된 아이디와 비밀번호를 불러와서 화면에 표시
            if let savedId = KeychainHelper.shared.load(key: "srt_id") {
                self.id = savedId
            }
            if let savedPassword = KeychainHelper.shared.load(key: "srt_password") {
                self.password = savedPassword
            }
        }
        // 알림창 표시
        .alert("로그인 결과", isPresented: $showingAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
        // 로그인 중일 때 로딩 인디케이터 표시
        .overlay {
            if isLoading {
                ProgressView("로그인 중...")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }
        }
    }
    
    // 아이디 타입(회원번호, 이메일, 전화번호)을 결정하는 헬퍼 함수
    private func getLoginType(for id: String) -> String {
        // 이메일 정규식 (간단화)
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        // 전화번호 정규식 (간단화, 하이픈 포함 가능)
        let phoneRegex = "^01(?:0|1|[6-9])-(?:\\d{3}|\\d{4})-\\d{4}$"
        
        if id.range(of: emailRegex, options: .regularExpression) != nil {
            return "2" // 이메일
        } else if id.range(of: phoneRegex, options: .regularExpression) != nil {
            return "3" // 전화번호
        } else {
            return "1" // 회원번호
        }
    }
    
    // SRT 로그인 요청을 처리하는 비동기 함수
    private func loginSRT() async {
        isLoading = true // 로딩 시작
        alertMessage = ""
        showingAlert = false
        
        // 전화번호인 경우 하이픈 제거
        var processedId = id
        if getLoginType(for: id) == "3" {
            processedId = id.replacingOccurrences(of: "-", with: "")
        }
        
        // 요청 URL
        guard let url = URL(string: "https://app.srail.or.kr:443/apb/selectListApb01080_n.do") else {
            alertMessage = "잘못된 URL입니다."
            showingAlert = true
            isLoading = false
            return
        }
        
        // 요청 바디 데이터 구성
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "auto", value: "Y"),
            URLQueryItem(name: "check", value: "Y"),
            URLQueryItem(name: "page", value: "menu"),
            URLQueryItem(name: "deviceKey", value: "-"),
            URLQueryItem(name: "customerYn", value: ""),
            URLQueryItem(name: "login_referer", value: "https://app.srail.or.kr:443/main/main.do"),
            URLQueryItem(name: "srchDvCd", value: getLoginType(for: id)),
            URLQueryItem(name: "srchDvNm", value: processedId),
            URLQueryItem(name: "hmpgPwdCphd", value: password)
        ]
        
        guard let httpBody = components.query?.data(using: .utf8) else {
            alertMessage = "요청 데이터 구성 실패."
            showingAlert = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // srt.py의 User-Agent 및 Default Headers 적용
        request.setValue("Mozilla/5.0 (Linux; Android 14; SM-S912N Build/UP1A.231005.007; wv) AppleWebKit/537.36(KHTML, like Gecko) Version/4.0 Chrome/131.0.6778.260 Mobile Safari/537.36SRT-APP-Android V.2.0.33", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                alertMessage = "서버 응답 오류."
                showingAlert = true
                isLoading = false
                return
            }
            
            // 응답 데이터를 문자열로 변환하여 파싱
            if let responseString = String(data: data, encoding: .utf8) {
                print("SRT Login Response: \(responseString)") // 디버깅을 위해 응답 전체 출력
                
                if responseString.contains("존재하지않는 회원입니다") || responseString.contains("비밀번호 오류") {
                    alertMessage = "아이디 또는 비밀번호가 올바르지 않습니다."
                } else if responseString.contains("Your IP Address Blocked") {
                    alertMessage = "IP 주소가 차단되었습니다."
                } else if responseString.contains("userMap") {
                    // 로그인 성공으로 간주 (더 정교한 파싱 필요)
                    alertMessage = "로그인 성공!"
                    // 키체인에 아이디와 비밀번호 저장
                    KeychainHelper.shared.save(key: "srt_id", value: id)
                    KeychainHelper.shared.save(key: "srt_password", value: password)
                } else {
                    alertMessage = "알 수 없는 로그인 오류가 발생했습니다."
                }
            } else {
                alertMessage = "응답 데이터를 읽을 수 없습니다."
            }
            
        } catch {
            alertMessage = "네트워크 오류: \(error.localizedDescription)"
        }
        
        showingAlert = true // 알림창 표시
        isLoading = false // 로딩 종료
    }
}

#Preview {
    NavigationView {
        SRTView()
    }
}
