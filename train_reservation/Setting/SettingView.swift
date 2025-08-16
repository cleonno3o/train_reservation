//
//  SettingView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// 설정 화면을 위한 View
struct SettingView: View {
    var body: some View {
        // List는 테이블 형태의 목록을 만듦
        List {
            // Section은 연관된 항목들을 그룹화
            Section(header: Text("계정 정보")) {
                // 각 항목은 NavigationLink로 감싸서 다른 화면으로 이동 가능
                NavigationLink(destination: SRTAccountView()) {
                    // Label은 아이콘과 텍스트를 함께 표시
                    Label("SRT", systemImage: "person.badge.key.fill")
                }
                
                NavigationLink(destination: KTXAccountView()) {
                    Label("KTX", systemImage: "person.badge.key.fill")
                }
            }
            
            Section(header: Text("결제 수단")) {
                NavigationLink(destination: PaymentSettingView()) {
                    Label("결제", systemImage: "creditcard.fill")
                }
            }
        }
        .navigationTitle("설정") // 네비게이션 바 제목
        .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
    }
}

#Preview {
    // 미리보기에서 네비게이션 제목을 확인하기 위해 NavigationView 사용
    NavigationView {
        SettingView()
    }
}
