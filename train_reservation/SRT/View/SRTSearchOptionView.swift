//
//  SRTSearchOptionView.swift
//  train_reservation
//
//  Created by sumin on 8/3/25.
//

import SwiftUI

// SRT 열차 조회 옵션 화면을 위한 View
struct SRTSearchOptionView: View {
    // SRTAPIClient 인스턴스를 환경 객체로 주입받음
    @EnvironmentObject var srtAPIClient: SRTAPIClient
    
    // 출발역, 도착역, 승객 수, 날짜, 시간을 저장하는 상태 변수
    @State private var departureStation = "수서"
    @State private var arrivalStation = "부산"
    @State private var passengerCount = 1
    @State private var selectedDate = Date() // 현재 날짜로 초기화
    @State private var selectedTime = Date() // 현재 시간으로 초기화
    
    // 역 선택 시트 표시 여부
    @State private var showingDepartureStationSelection = false
    @State private var showingArrivalStationSelection = false
    
    // 열차 조회 로딩 및 알림
    @State private var isLoadingTrainSearch = false
    @State private var showingTrainSearchAlert = false
    @State private var trainSearchAlertMessage = ""
    
    // 열차 조회 결과 화면으로 이동할지 여부
    @State private var navigateToTrainResult = false
    
    // 조회된 열차 목록
    @State private var trainArray: [SRTTrain] = []
    
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
                        SRTStationSelectionView(selectedStation: $departureStation)
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
                        SRTStationSelectionView(selectedStation: $arrivalStation)
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
                        // 새로 만든 함수를 비동기 Task로 실행
                        Task {
                            await performNetFunnelAndSearch()
                        }
                    }
                }
            }
            .navigationTitle("열차 조회") // 네비게이션 바 제목
            .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
            .navigationDestination(isPresented: $navigateToTrainResult) {
                SRTTrainResultView(trains: trainArray)
            }
        }

        // 열차 조회 로딩 인디케이터
        .overlay {
            if isLoadingTrainSearch {
                ProgressView("열차 조회 중...")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }
        }
        // 열차 조회 결과 알림
        .alert("열차 조회 결과", isPresented: $showingTrainSearchAlert) {
            Button("확인") { }
        } message: {
            Text(trainSearchAlertMessage)
        }
    }
    
    // NetFunnelHelper를 실행하고 열차를 조회하는 새로운 함수
    private func performNetFunnelAndSearch() async {
        isLoadingTrainSearch = true // 로딩 인디케이터 표시

        let netFunnelHelper = NetFunnelHelper(debug: true) // 디버그 메시지를 보기 위해 true로 설정
        do {
            // NetFunnelHelper를 실행하여 인증 키를 받아옴
            let netfunnelKey = try await netFunnelHelper.run()
            
            // 성공적으로 키를 받으면, 기존의 searchTrains 함수를 호출
            print("NetFunnel Key Received")
            await requestTrainSearch(netfunnelKey: netfunnelKey)
            
        } catch {
            // 실패 시, 사용자에게 알림
            trainSearchAlertMessage = "넷퍼넬 인증에 실패했습니다: \(error.localizedDescription)"
            showingTrainSearchAlert = true
        }
        
        isLoadingTrainSearch = false // 로딩 인디케이터 숨김
    }

    // 열차 조회 API 호출 함수
    private func requestTrainSearch(netfunnelKey: String) async {
        isLoadingTrainSearch = true
        trainSearchAlertMessage = ""
        showingTrainSearchAlert = false
        
        // 날짜 및 시간 포맷팅
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dptDt = dateFormatter.string(from: selectedDate)
        
        dateFormatter.dateFormat = "HHmmss"
        let dptTm = dateFormatter.string(from: selectedTime)
        
        // 출발역, 도착역 코드로 변환
        guard let dptRsStnCd = SRTConstant.STATION_CODE[departureStation],
              let arvRsStnCd = SRTConstant.STATION_CODE[arrivalStation] else {
            trainSearchAlertMessage = "선택된 역의 코드를 찾을 수 없습니다."
            showingTrainSearchAlert = true
            isLoadingTrainSearch = false
            return
        }
        
        // 열차 조회 API 호출
        if let fetchedTrainArray = await srtAPIClient.searchTrain(
            departureStationCode: dptRsStnCd,
            arrivalStationCode: arvRsStnCd,
            date: dptDt,
            time: dptTm,
            passengerCount: passengerCount,
            netfunnelKey: netfunnelKey
        ) {
            self.trainArray = fetchedTrainArray
            print("Fetched Trains: \(self.trainArray)") // Add this line
            navigateToTrainResult = true
        } else {
            trainSearchAlertMessage = "열차 조회 실패."
            showingTrainSearchAlert = true
        }
        
        isLoadingTrainSearch = false
    }
}

#Preview {
    NavigationView {
        SRTSearchOptionView()
            .environmentObject(SRTAPIClient())
    }
}
