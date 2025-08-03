//
//  SRTTrainResultView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// SRT 열차 조회 결과를 표시하는 View
struct SRTTrainResultView: View {
    var body: some View {
        VStack {
            Text("열차 조회 결과가 여기에 표시됩니다.")
        }
        .navigationTitle("열차 조회 결과")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SRTTrainResultView()
    }
}
