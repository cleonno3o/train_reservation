//
//  ContentView.swift
//  train_reservation
//
//  Created by 주수민 on 8/3/25.
//

import SwiftUI

// 앱의 메인 화면. 각 기능 화면으로 연결하는 네비게이션 역할
struct ContentView: View {
    var body: some View {
        // 화면 간 이동을 관리하는 NavigationView
        NavigationView {
            // 요소들을 세로로 정렬하는 VStack
            VStack(spacing: 20) {
                // SRTView로 이동하는 네비게이션 링크
                NavigationLink(destination: SRTView()) {
                    Text("SRT")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // KTXView로 이동하는 네비게이션 링크
                NavigationLink(destination: KTXView()) {
                    Text("KTX")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // SettingsView로 이동하는 네비게이션 링크
                NavigationLink(destination: SettingsView()) {
                    Text("설정")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding() // VStack 주변 여백
            .navigationTitle("기차 예매") // 화면 상단 제목
        }
    }
}

// Xcode 미리보기를 위한 코드
#Preview {
    ContentView()
}
