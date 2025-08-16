//
//  SRTTrainResultView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// SRT 열차 조회 결과를 표시하는 View
struct SRTTrainResultView: View {
    // SRTSearchOptionView에서 전달받을 열차 목록
    let trains: [SRTTrain]
    
    var body: some View {
        VStack {
            if trains.isEmpty {
                Text("조회된 열차가 없습니다.")
                    .foregroundColor(.gray)
            } else {
                List(trains) {
                    train in
                    VStack(alignment: .leading) {
                        Text("\(train.trainName) \(train.trainNumber)")
                            .font(.headline)
                        Text("출발: \(train.depStationName) (\(train.depTime.prefix(2)):\(train.depTime.suffix(4).prefix(2))) - 도착: \(train.arrStationName) (\(train.arrTime.prefix(2)):\(train.arrTime.suffix(4).prefix(2)))")
                            .font(.subheadline)
                        Text("일반실: \(train.generalSeatState) / 특실: \(train.specialSeatState)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("열차 조회 결과")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        // 미리보기에서는 빈 열차 목록을 전달
        SRTTrainResultView(trains: [])
    }
}