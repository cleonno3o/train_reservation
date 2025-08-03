//
//  SRTAccountView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// SRT 계정 정보 입력을 위한 View
struct SRTAccountView: View {
    // @State는 View의 상태를 저장하는 변수. 값이 바뀌면 화면이 자동으로 업데이트됨.
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        // Form은 설정이나 데이터 입력에 적합한 UI를 제공
        Form {
            Section(header: Text("SRT 계정 정보")) {
                // TextField는 사용자 ID를 입력받는 필드
                // text: $username은 username 변수와 입력을 실시간으로 연동 (바인딩)
                TextField("SRT 아이디", text: $username)
                
                // SecureField는 비밀번호 입력을 위한 필드 (입력값이 가려짐)
                SecureField("비밀번호", text: $password)
            }
            
            Section {
                // 버튼을 누르면 클로저 안의 코드가 실행됨
                Button("저장") {
                    // 지금은 입력된 값을 콘솔에 출력하는 동작만 수행
                    print("SRT 계정 저장됨: ID - \(username), PW - \(password)")
                }
            }
        }
        .navigationTitle("SRT 계정 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SRTAccountView()
    }
}
