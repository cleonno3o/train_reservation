//
//  SettingsView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// 설정 화면을 위한 View
struct SettingsView: View {
    var body: some View {
        VStack {
            Text("설정 기능 구현 영역")
        }
        .navigationTitle("설정") // 네비게이션 바 제목
        .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
    }
}

#Preview {
    // 미리보기에서 네비게이션 제목을 확인하기 위해 NavigationView 사용
    NavigationView {
        SettingsView()
    }
}
