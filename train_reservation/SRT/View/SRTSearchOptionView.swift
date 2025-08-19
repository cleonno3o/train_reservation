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
    
    // 출발역, 도착역, 승객 수, 날짜, 시간, 좌석 등급을 저장하는 상태 변수
    @State private var departureStation = "수서"
    @State private var arrivalStation = "부산"
    @State private var passengerCount = 1
    @State private var selectedDate = Date() // 현재 날짜로 초기화
    @State private var selectedTime = Date() // 현재 시간으로 초기화
    @State private var seatPrefernce = SeatPreference.generalFirst
    
    // 역 선택 시트 표시 여부
    @State private var showingDepartureStationSelection = false
    @State private var showingArrivalStationSelection = false
    
    // 열차 조회 로딩 및 알림
    @State private var isLoadingTrainSearch = false
    @State private var showingTrainSearchAlert = false
    @State private var trainSearchAlertMessage = ""
    
    @State private var showingTrainSelectionSheet = false
    
    // 조회된 열차 목록
    @State private var trainArray: [SRTTrain] = []

    // 예매 취소 플래그
    @State private var isReservationCancelled = false

    // 예매 결과 알림
    @State private var showingReservationResultAlert = false
    @State private var reservationResultMessage = ""
    
    // 예매 로딩 및 시간 표시
    @State private var showingReservationOverlay = false
    @State private var reservationStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var tryCount: Int = 0
    
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
                
                Section(header: Text("예약 옵션")) {
                    Picker("좌석 우선순위", selection: $seatPrefernce) {
                        // SeatPreference.swift 파일에 정의된 모든 케이스를 순회하며 메뉴 생성
                        ForEach(SeatPreference.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                Section {
                    Button("열차 조회") {
                        // 새로 만든 함수를 비동기 Task로 실행
                        Task {
                            await requestSearch()
                        }
                    }
                }
            }
            .navigationTitle("열차 조회") // 네비게이션 바 제목
            .navigationBarTitleDisplayMode(.inline) // 제목을 작은 형태로 표시
            .sheet(isPresented: $showingTrainSelectionSheet) {
                SRTTrainSelectionView(trainArray: trainArray) { selectedTrainArray in
                    print("Selected Trains: \(selectedTrainArray)")
                    // 예매 로직 시작
                    self.isReservationCancelled = false // 예매 취소 플래그 초기화
                    self.showingReservationOverlay = true
                    self.reservationStartTime = Date()
                    Task {
                        await performReservation(selectedTrainArray: selectedTrainArray)
                    }
                }
            }
        }

        // 열차 조회 로딩 인디케이터
        .overlay {
            if isLoadingTrainSearch {
                ProgressView("열차 조회 중...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        // 예매 대기 로딩 인디케이터 및 시간 표시
        .overlay {
            if showingReservationOverlay {
                GeometryReader {
                    geometry in
                    VStack {
                        ProgressView()
                        Text("예매 시도 중...")
                            .font(.headline)
                        Text(String(format: "%d번 시도", tryCount))
                            .font(.subheadline)
                        Text(String(format: "%.0f초 경과", elapsedTime))
                            .font(.subheadline)
                        Divider()
                            .padding(.vertical, 5)
                        Button(action: {
                            self.isReservationCancelled = true // 예매 취소 플래그 설정
                            self.showingReservationOverlay = false
                        }) {
                            Text("취소")
                                .foregroundColor(.red)
                                .font(.body)
                        }
                    }
                    .padding(20)
                    .background(.regularMaterial)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .frame(width: geometry.size.width * 0.6)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .onAppear {
                        // Start timer to update elapsed time
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                            if self.showingReservationOverlay, let startTime = self.reservationStartTime {
                                self.elapsedTime = Date().timeIntervalSince(startTime)
                                self.tryCount += 1
                            } else {
                                timer.invalidate()
                            }
                        }.fire()
                    }
                    .onDisappear {
                        // Reset elapsed time when overlay disappears
                        self.elapsedTime = 0
                        self.tryCount = 0
                    }
                }
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
    private func requestSearch() async {
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
        if let fetchedTrainArray = await srtAPIClient.search(
            departureStationCode: dptRsStnCd,
            arrivalStationCode: arvRsStnCd,
            date: dptDt,
            time: dptTm,
            passengerCount: passengerCount
        ) {
            self.trainArray = fetchedTrainArray
            print("Fetched Trains: \(self.trainArray)") // Add this line
            showingTrainSelectionSheet = true
        } else {
            trainSearchAlertMessage = "열차 조회 실패."
            showingTrainSearchAlert = true
        }
        
        isLoadingTrainSearch = false
//        isLoadingTrainSearch = true // 로딩 인디케이터 표시

//        let netFunnelHelper = NetFunnelHelper(debug: true) // 디버그 메시지를 보기 위해 true로 설정
//        do {
            // NetFunnelHelper를 실행하여 인증 키를 받아옴
//            let netfunnelKey = try await netFunnelHelper.run()
            
//            self.currentNetfunnelKey = netfunnelKey  넷퍼넬 키 저장
            
            // 성공적으로 키를 받으면, 기존의 searchTrains 함수를 호출
//            print("NetFunnel Key Received")
//            await requestTrainSearch()
//            
//        } catch {
//            // 실패 시, 사용자에게 알림
//            trainSearchAlertMessage = "넷퍼넬 인증에 실패했습니다: \(error.localizedDescription)"
//            showingTrainSearchAlert = true
//        }
//        
//        isLoadingTrainSearch = false // 로딩 인디케이터 숨김
    }

    // 열차 조회 API 호출 함수
//    private func requestTrainSearch() async {
//
//    }
    

    // 예매 로직 구현 함수
    private func performReservation(selectedTrainArray: [SRTTrain]) async {
        
        // 날짜 및 시간 포맷팅 (예매 시 재사용)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dptDt = dateFormatter.string(from: selectedDate)

        dateFormatter.dateFormat = "HHmmss"
        let dptTm = dateFormatter.string(from: selectedTime)

        // 출발역, 도착역 코드로 변환 (예매 시 재사용)
        guard let dptRsStnCd = SRTConstant.STATION_CODE[departureStation],
              let arvRsStnCd = SRTConstant.STATION_CODE[arrivalStation] else {
            reservationResultMessage = "선택된 역의 코드를 찾을 수 없습니다."
            showingReservationResultAlert = true
            showingReservationOverlay = false
            return
        }

        while !isReservationCancelled {
            print("예매 시도 중...", tryCount)
            // 최신 열차 정보 다시 조회
            if let updatedTrainArray = await srtAPIClient.search(
                departureStationCode: dptRsStnCd,
                arrivalStationCode: arvRsStnCd,
                date: dptDt,
                time: dptTm,
                passengerCount: passengerCount
            ) {
                for selectedTrain in selectedTrainArray {
                    // 선택된 열차와 일치하는 최신 정보 찾기
                    if let currentTrain = updatedTrainArray.first(where: { $0.trainCode == selectedTrain.trainCode && $0.depTime == selectedTrain.depTime }) {
                        // 좌석 가용성 확인 (간단화: 일반실 또는 특실이 '예약가능'인 경우)
                        if checkTrain(train: currentTrain, seatPref: seatPrefernce) {
                            print("좌석 발견! 예매 시도: \(currentTrain.trainName) \(currentTrain.trainNumber)")
//                            if await srtAPIClient.reserve(train: currentTrain, passengerArray: [Adult(count: 1)], preference: seatPrefernce) {
                            await srtAPIClient.reserve(train: currentTrain, passengerArray: [Adult(count: 1)], preference: seatPrefernce)
                            reservationResultMessage = "예매 성공!"
                            showingReservationResultAlert = true
                            showingReservationOverlay = false
                            return
//                            }
                        }
//                        let isGeneralAvailable = currentTrain.generalSeatState.contains("예약가능")
//                        let isSpecialAvailable = currentTrain.specialSeatState.contains("예약가능")

//                        if isGeneralAvailable || isSpecialAvailable {
//                            print("좌석 발견! 예매 시도: \(currentTrain.trainName) \(currentTrain.trainNumber)")
//                            // TODO: SeatPreference는 사용자 선택에 따라 달라져야 함. 일단 일반실 우선으로 가정.
//                            let preference: SeatPreference = isGeneralAvailable ? .generalOnly : .specialOnly
//
//                            if await srtAPIClient.reserve(<#T##train: SRTTrain##SRTTrain#>, preference: <#T##SeatPreference#>) {
//                                reservationResultMessage = "예매 성공!"
//                                showingReservationResultAlert = true
//                                showingReservationOverlay = false
//                                return // 예매 성공 시 함수 종료
//                            } else {
//                                print("예매 실패: \(currentTrain.trainName) \(currentTrain.trainNumber)")
//                            }
//                        }
                    }
                }
            } else {
                print("열차 정보 업데이트 실패.")
            }

            // 예매 취소되지 않았다면 1초 대기 후 재시도
            if !isReservationCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
            }
        }

        // 루프 종료 (취소되었거나 예매 성공)
        if isReservationCancelled {
            reservationResultMessage = "예매가 취소되었습니다."
            showingReservationResultAlert = true
            showingReservationOverlay = false
        }
    }
    
    private func checkTrain(train: SRTTrain, seatPref: SeatPreference) -> Bool {
        if !train.isSeatAvail() {
            return train.isReserveStandbyAvail()
        }
        if seatPref == SeatPreference.generalFirst || seatPref == SeatPreference.specialFirst {
            return train.isSeatAvail()
        }
        if seatPref == SeatPreference.generalOnly {
            return train.isGeneralSeatAvail()
        }
        return train.isSpecialSeatAvail()
    }
}

#Preview {
    NavigationView {
        SRTSearchOptionView()
            .environmentObject(SRTAPIClient())
    }
}
