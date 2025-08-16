//
//  train_reservationApp.swift
//  train_reservation
//
//  Created by 주수민 on 8/3/25.
//

import SwiftUI

@main
struct train_reservationApp: App {
    // SRTAPIClient 인스턴스를 앱 전체에서 공유하기 위한 StateObject
    @StateObject var srtAPIClient = SRTAPIClient()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(srtAPIClient) // SRTAPIClient를 환경 객체로 등록
        }
    }
}
