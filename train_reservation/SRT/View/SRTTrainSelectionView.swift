//
//  SRTTrainResultView.swift
//  train_reservation
//
//  Created by sumin on 8/3/25.
//

import SwiftUI

// SRT 열차 조회 결과를 표시하는 View
struct SRTTrainSelectionView: View {
    // SRTSearchOptionView에서 전달받을 열차 목록
    let trainArray: [SRTTrain]
    // 선택된 열차들의 ID를 저장하는 Set
    @State private var currSelectedSet: Set<SRTTrain.ID> = []
    // 현재 View를 닫기 위한 환경 변수
    @Environment(\.dismiss) var dismiss
    // 선택된 열차들을 상위 뷰로 전달하기 위한 클로저
    var onReserveSelected: ([SRTTrain]) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if trainArray.isEmpty {
                    Text("조회된 열차가 없습니다.")
                        .foregroundColor(.gray)
                } else {
                    // List에 selection 바인딩 추가
                    List(trainArray) {
                        train in
                        HStack { // Use HStack to place checkmark next to content
                            VStack(alignment: .leading) {
                                Text("\(train.trainName) \(train.trainNumber)")
                                    .font(.headline)
                                Text("출발: \(train.depStationName) (\(train.depTime.prefix(2)):\(train.depTime.suffix(4).prefix(2))) - 도착: \(train.arrStationName) (\(train.arrTime.prefix(2)):\(train.arrTime.suffix(4).prefix(2)))")
                                    .font(.subheadline)
                                Text(showStatusInfo(for: train))
                                //                            Text("특실: \(train.specialSeatState) / 일반실: \(train.generalSeatState)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer() // Pushes content to left and checkmark to right
                            if currSelectedSet.contains(train.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle()) // Make the whole row tappable
                        .onTapGesture {
                            if currSelectedSet.contains(train.id) {
                                currSelectedSet.remove(train.id)
                            } else {
                                currSelectedSet.insert(train.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("열차 조회 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss() // 시트 닫기
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("확인") { // "예매하기"를 "확인"으로 변경
                        // 선택된 열차들을 필터링
                        let selectedTrainArray = trainArray.filter { currSelectedSet.contains($0.id) }
                        // 선택된 열차들을 클로저를 통해 상위 뷰로 전달
                        onReserveSelected(selectedTrainArray)
                        dismiss() // 현재 뷰 닫기
                    }
                    // 선택된 열차가 없으면 버튼 비활성화
                    .disabled(currSelectedSet.isEmpty)
                }
            }
        }
        //        #Preview {
        //            NavigationView {
        //                // 미리보기에서는 빈 열차 목록을 전달
        //                SRTTrainSelectionView(trains: [])
        //            }
        //        }
    }
    private func showStatusInfo(for train: SRTTrain) -> String {
        var statusMsg = "특실: \(train.specialSeatState) / 일반실: \(train.generalSeatState)"
        if train.reservePossibleCode == 9 {
            print("reserve possible")
            statusMsg += " / 예약대기: 가능"
        } else if train.reservePossibleCode == 0 {
            statusMsg += " / 예약대기: 매진"
        }
        return statusMsg
    }
}
