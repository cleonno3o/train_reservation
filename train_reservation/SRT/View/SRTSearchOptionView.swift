//
//  SRTSearchOptionView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
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
    
    // 넷퍼넬 키 및 웹뷰 표시 여부
    @State private var netfunnelKey: String? = nil
    @State private var showingNetFunnelWebView = false
    
    // 열차 조회 로딩 및 알림
    @State private var isLoadingTrainSearch = false
    @State private var showingTrainSearchAlert = false
    @State private var trainSearchAlertMessage = ""
    
    // 열차 조회 결과 화면으로 이동할지 여부
    @State private var navigateToTrainResult = false
    
    // 조회된 열차 목록
    @State private var trains: [SRTTrain] = []
    
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
                        // 열차 조회 버튼 클릭 시 넷퍼넬 웹뷰 표시
                        showingNetFunnelWebView = true
                    }
                }
            }
            .navigationTitle("열차 조회") // 네비게이션 바 제목
            .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
            .navigationDestination(isPresented: $navigateToTrainResult) {
                SRTTrainResultView(trains: trains)
            }
        }
        // 웹뷰 테스트를 위해 구글을 띄우는 시트
        .sheet(isPresented: $showingNetFunnelWebView) {
            // NetFunnelWebView에 구글 URL을 전달하여 테스트합니다.
            NetFunnelWebView(url: URL(string: "https://www.google.com")!) { key in
                // 원래 이 부분에서 넷퍼넬 키를 받아 처리하지만, 지금은 테스트 중이므로 비워둡니다.
                print("WebView onCompletion closure called. Received key: \(key ?? "nil")")
                self.showingNetFunnelWebView = false // 웹뷰를 닫습니다.
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
    
    // 열차 조회 API 호출 함수
    private func searchTrains(netfunnelKey: String) async {
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
        if let fetchedTrains = await srtAPIClient.searchTrains(
            departureStationCode: dptRsStnCd,
            arrivalStationCode: arvRsStnCd,
            date: dptDt,
            time: dptTm,
            passengerCount: passengerCount,
            netfunnelKey: netfunnelKey
        ) {
            self.trains = fetchedTrains
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