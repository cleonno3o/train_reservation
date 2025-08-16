//
//  KTXAccountView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// KTX 계정 정보 입력을 위한 View
struct KTXSettingView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        Form {
            Section(header: Text("KTX 계정 정보")) {
                TextField("코레일 아이디", text: $username)
                SecureField("비밀번호", text: $password)
            }
            
            Section {
                Button("저장") {
                    // KeychainHelper를 사용해 ID와 비밀번호를 안전하게 저장
                    KeychainHelper.shared.save(key: "ktx_username", value: username)
                    KeychainHelper.shared.save(key: "ktx_password", value: password)
                    print("KTX 계정 정보가 키체인에 저장되었습니다.")
                }
            }
        }
        .navigationTitle("KTX 계정 설정")
        .navigationBarTitleDisplayMode(.inline)
        // View가 화면에 나타날 때 실행되는 코드
        .onAppear {
            // 키체인에서 저장된 ID와 비밀번호를 불러와서 화면에 표시
            if let savedUsername = KeychainHelper.shared.load(key: "ktx_username") {
                self.username = savedUsername
            }
            if let savedPassword = KeychainHelper.shared.load(key: "ktx_password") {
                self.password = savedPassword
            }
        }
    }
}

#Preview {
    NavigationView {
        KTXSettingView()
    }
}
