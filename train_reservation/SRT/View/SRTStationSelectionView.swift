//
//  SRTStationSelectionView.swift
//  train_reservation
//
//  Created by sumin on 8/3/25.
//

import SwiftUI

// 역 선택 화면을 위한 View
struct SRTStationSelectionView: View {
    // 선택된 역을 외부 View와 동기화하기 위한 Binding 변수
    @Binding var selectedStation: String
    // 현재 View를 닫기 위한 환경 변수
    @Environment(\.dismiss) var dismiss
    
    // SRTConstant에서 모든 역 이름 목록을 가져옴
    let stations = SRTConstant.STATION_CODE.keys.sorted()
    
    var body: some View {
        NavigationView {
            List(stations, id: \.self) {
                station in
                Button(station) {
                    selectedStation = station // 선택된 역 업데이트
                    dismiss() // View 닫기
                }
            }
            .navigationTitle("역 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss() // 취소 버튼 클릭 시 View 닫기
                    }
                }
            }
        }
    }
}

#Preview {
    // 미리보기에서는 Binding 변수를 .constant로 제공
    SRTStationSelectionView(selectedStation: .constant("수서"))
}
