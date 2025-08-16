//
//  PaymentSettingView.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import SwiftUI

// 결제 정보 입력을 위한 View
struct PaymentSettingView: View {
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
                
                TextField("유효기간 (YY/MM)", text: $expiryDate)
                    .keyboardType(.numberPad)
                    // expiryDate 값이 변경될 때마다 아래 코드를 실행
                    .onChange(of: expiryDate) { _, newValue in
                        let formatted = formatExpiryDate(newValue)
                        // 무한 루프를 방지하기 위해, 변경된 경우에만 값을 업데이트
                        if expiryDate != formatted {
                            expiryDate = formatted
                        }
                    }
            }
            
            Section {
                Button("저장") {
                    // KeychainHelper를 사용해 결제 정보를 안전하게 저장
                    KeychainHelper.shared.save(key: "payment_cardNumber", value: cardNumber)
                    KeychainHelper.shared.save(key: "payment_cardPassword", value: cardPassword)
                    KeychainHelper.shared.save(key: "payment_birthDate", value: birthDate)
                    // 유효기간은 숫자만 추출하여 저장
                    let expiryDigitsOnly = expiryDate.filter { "0123456789".contains($0) }
                    KeychainHelper.shared.save(key: "payment_expiryDate", value: expiryDigitsOnly)
                    print("결제 정보가 키체인에 저장되었습니다.")
                }
            }
        }
        .navigationTitle("결제 설정")
        .navigationBarTitleDisplayMode(.inline)
        // View가 화면에 나타날 때 실행되는 코드
        .onAppear {
            // 키체인에서 저장된 결제 정보를 불러와서 화면에 표시
            if let savedCardNumber = KeychainHelper.shared.load(key: "payment_cardNumber") {
                self.cardNumber = savedCardNumber
            }
            if let savedCardPassword = KeychainHelper.shared.load(key: "payment_cardPassword") {
                self.cardPassword = savedCardPassword
            }
            if let savedBirthDate = KeychainHelper.shared.load(key: "payment_birthDate") {
                self.birthDate = savedBirthDate
            }
            if let savedExpiryDate = KeychainHelper.shared.load(key: "payment_expiryDate") {
                self.expiryDate = savedExpiryDate
            }
        }
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
    
    // 유효기간 형식(YY/MM)을 자동으로 맞춰주는 함수
    private func formatExpiryDate(_ date: String) -> String {
        // 1. 입력된 문자열에서 숫자만 추출
        var digitsOnly = date.filter { "0123456789".contains($0) }
        
        // 2. 최대 4자리(YYMM)로 제한
        if digitsOnly.count > 4 {
            digitsOnly = String(digitsOnly.prefix(4))
        }
        
        // 3. 2자리(YY) 뒤에 슬래시(/) 추가
        var result = ""
        for (index, digit) in digitsOnly.enumerated() {
            result.append(digit)
            if index == 1 && digitsOnly.count > 2 {
                result.append("/")
            }
        }
        
        return result
    }
}

#Preview {
    NavigationView {
        PaymentSettingView()
    }
}