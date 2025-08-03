//
//  KTXAccountView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// KTX 계정 정보 입력을 위한 View
struct KTXAccountView: View {
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
                    print("KTX 계정 저장됨: ID - \(username), PW - \(password)")
                }
            }
        }
        .navigationTitle("KTX 계정 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        KTXAccountView()
    }
}
