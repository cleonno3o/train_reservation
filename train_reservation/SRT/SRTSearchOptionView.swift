//
//  SRTSearchOptionView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// SRT 열차 조회 옵션 화면을 위한 View
struct SRTSearchOptionView: View {
    // 출발역, 도착역, 승객 수, 날짜, 시간을 저장하는 상태 변수
    @State private var departureStation = "수서"
    @State private var arrivalStation = "부산"
    @State private var passengerCount = 1
    @State private var selectedDate = Date() // 현재 날짜로 초기화
    @State private var selectedTime = Date() // 현재 시간으로 초기화
    
    // 역 선택 시트 표시 여부
    @State private var showingDepartureStationSelection = false
    @State private var showingArrivalStationSelection = false
    
    // 열차 조회 결과 화면으로 이동할지 여부
    @State private var navigateToTrainResult = false
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("출발/도착 정보")) {
                    // 출발역 선택 버튼
                    Button(action: {
                        showingDepartureStationSelection = true
                    }) {
                        HStack {
                            Text("출발역")
                            Spacer()
                            Text(departureStation)
                                .foregroundColor(.blue)
                        }
                    }
                    .sheet(isPresented: $showingDepartureStationSelection) {
                        StationSelectionView(selectedStation: $departureStation)
                    }
                    
                    // 도착역 선택 버튼
                    Button(action: {
                        showingArrivalStationSelection = true
                    }) {
                        HStack {
                            Text("도착역")
                            Spacer()
                            Text(arrivalStation)
                                .foregroundColor(.blue)
                        }
                    }
                    .sheet(isPresented: $showingArrivalStationSelection) {
                        StationSelectionView(selectedStation: $arrivalStation)
                    }
                }
                
                Section(header: Text("승객 정보")) {
                    Stepper("승객 수: \(passengerCount)명", value: $passengerCount, in: 1...9)
                }
                
                Section(header: Text("날짜/시간")) {
                    DatePicker("날짜", selection: $selectedDate, in: Date()...Calendar.current.date(byAdding: .month, value: 1, to: Date())!, displayedComponents: .date)
                    DatePicker("시간", selection: $selectedTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Button("열차 조회") {
                        // 열차 조회 버튼 클릭 시 결과 화면으로 이동
                        navigateToTrainResult = true
                    }
                }
            }
            .navigationTitle("열차 조회") // 네비게이션 바 제목
            .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
            .navigationDestination(isPresented: $navigateToTrainResult) {
                SRTTrainResultView()
            }
        }
    }
}

#Preview {
    NavigationView {
        SRTSearchOptionView()
    }
}
