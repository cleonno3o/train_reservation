//
//  KTXView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// KTX 예매 화면을 위한 View
struct KTXView: View {
    var body: some View {
        VStack {
            Text("KTX 예매 기능 구현 영역")
        }
        .navigationTitle("KTX 예매") // 네비게이션 바 제목
        .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
    }
}

#Preview {
    // 미리보기에서 네비게이션 제목을 확인하기 위해 NavigationView 사용
    NavigationView {
        KTXView()
    }
}
