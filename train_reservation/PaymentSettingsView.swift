//
//  PaymentSettingsView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// 결제 정보 입력을 위한 View
struct PaymentSettingsView: View {
    @State private var cardNumber = ""
    @State private var cardPassword = ""
    @State private var birthDate = ""
    @State private var expiryDate = ""
    
    var body: some View {
        Form {
            Section(header: Text("카드 정보")) {
                TextField("카드 번호", text: $cardNumber)
                    .keyboardType(.numberPad) // 숫자 키패드 표시
                    // cardNumber 값이 변경될 때마다 아래 코드를 실행
                    .onChange(of: cardNumber) { _, newValue in
                        let formatted = formatCardNumber(newValue)
                        // 무한 루프를 방지하기 위해, 변경된 경우에만 값을 업데이트
                        if cardNumber != formatted {
                            cardNumber = formatted
                        }
                    }
                
                SecureField("카드 비밀번호 앞 2자리", text: $cardPassword)
                    .keyboardType(.numberPad)
                
                TextField("생년월일 (YYMMDD)", text: $birthDate)
                    .keyboardType(.numberPad)
                
                TextField("유효기간 (YYMM)", text: $expiryDate)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button("저장") {
                    print("결제 정보 저장됨: \(cardNumber), \(cardPassword), \(birthDate), \(expiryDate)")
                }
            }
        }
        .navigationTitle("결제 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 카드 번호 형식(XXXX-XXXX-XXXX-XXXX)을 자동으로 맞춰주는 함수
    private func formatCardNumber(_ number: String) -> String {
        // 1. 입력된 문자열에서 숫자만 추출
        var digitsOnly = number.filter { "0123456789".contains($0) }
        
        // 2. 최대 16자리로 제한
        if digitsOnly.count > 16 {
            digitsOnly = String(digitsOnly.prefix(16))
        }
        
        // 3. 4자리마다 하이픈(-) 추가
        var result = ""
        for (index, digit) in digitsOnly.enumerated() {
            if index > 0 && index % 4 == 0 {
                result.append("-")
            }
            result.append(digit)
        }
        
        return result
    }
}

#Preview {
    NavigationView {
        PaymentSettingsView()
    }
}
