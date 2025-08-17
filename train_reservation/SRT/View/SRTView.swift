//
//  SRTView.swift
//  train_reservation
//
//  Created by sumin on 8/3/25.
//

import SwiftUI

// SRT 로그인 및 예매 화면을 위한 View
struct SRTView: View {
    @EnvironmentObject var srtAPIClient: SRTAPIClient
    // 사용자 아이디와 비밀번호를 저장하는 상태 변수
    @State private var id = ""
    @State private var password = ""
    
    // 로그인 진행 상태를 나타내는 변수
    @State private var isLoading = false
    
    // 알림창 표시 여부 및 메시지
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 로그인 성공 시 열차 조회 화면으로 이동할지 여부
    @State private var navigateToTrainSearch = false
    
    var body: some View {
        VStack {
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
                Button("확인") {
                    // 로그인 성공 메시지일 경우에만 화면 전환
                    if alertMessage == "로그인 성공!" {
                        navigateToTrainSearch = true
                    }
                }
            } message: {
                Text(alertMessage)
            }
            // 로그인 중일 때 로딩 인디케이터 표시
            .overlay {
                if isLoading {
                    ProgressView("로그인 중...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(10)
                }
            }
            .navigationDestination(isPresented: $navigateToTrainSearch) {
                SRTSearchOptionView()
            }
        }
    }
    
    // SRT 로그인 요청을 처리하는 비동기 함수
    private func loginSRT() async {
        isLoading = true // 로딩 시작
        alertMessage = ""
        showingAlert = false

        let success = await srtAPIClient.login(id: id, password: password)

        if success {
            alertMessage = "로그인 성공!"
            // KeychainHelper.shared.save는 SRTSettingView에서 처리
        } else {
            alertMessage = "로그인 실패. 아이디 또는 비밀번호를 확인해주세요."
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
