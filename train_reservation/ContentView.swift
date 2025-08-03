//
//  ContentView.swift
//  train_reservation
//
//  Created by 주수민 on 8/3/25.
//

import SwiftUI

// ContentView는 앱의 메인 화면을 정의하는 구조체입니다.
// SwiftUI에서 화면의 한 단위는 View 프로토콜을 따르는 struct로 만듭니다.
struct ContentView: View {
    // body는 View가 실제로 어떻게 보일지를 정의하는 부분입니다.
    // 이 안에 있는 코드들이 화면의 내용을 구성합니다.
    var body: some View {
        // NavigationView는 화면 간 이동을 관리하고 상단에 제목을 표시해줍니다.
        NavigationView {
            // VStack은 요소들을 세로로 정렬하는 컨테이너입니다.
            // spacing: 20은 각 버튼 사이의 간격을 20으로 설정합니다.
            VStack(spacing: 20) {
                // NavigationLink는 다른 화면으로 이동하는 버튼을 만듭니다.
                // destination은 버튼을 눌렀을 때 보여줄 화면입니다.
                NavigationLink(destination: Text("SRT 예매 화면")) {
                    // 이 안의 코드는 버튼의 모양을 정의합니다.
                    Text("SRT")
                        .font(.title) // 글자 크기를 '제목' 스타일로 설정
                        .padding() // 텍스트 주변에 여백 추가
                        .frame(maxWidth: .infinity) // 가로 길이를 화면에 꽉 채움
                        .background(Color.blue) // 배경색을 파란색으로 설정
                        .foregroundColor(.white) // 글자색을 흰색으로 설정
                        .cornerRadius(10) // 모서리를 둥글게 만듦
                }

                NavigationLink(destination: Text("KTX 예매 화면")) {
                    Text("KTX")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: Text("설정 화면")) {
                    Text("설정")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding() // VStack 전체의 주변에 여백을 추가
            .navigationTitle("기차 예매") // 화면 상단에 표시될 제목
        }
    }
}

// #Preview는 Xcode 미리보기 화면을 위한 코드입니다.
// 앱을 실행하지 않고도 UI를 확인할 수 있습니다.
#Preview {
    ContentView()
}
