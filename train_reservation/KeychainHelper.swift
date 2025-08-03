//
//  KeychainHelper.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import Foundation
import Security

// 키체인 관련 작업을 쉽게 처리하기 위한 헬퍼 클래스
final class KeychainHelper {
    // 앱 전체에서 공유되는 단일 인스턴스 (싱글턴)
    static let shared = KeychainHelper()
    private init() {}
    
    // 키체인에 데이터를 저장하는 함수
    func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // 이미 키가 존재하면 업데이트, 없으면 새로 추가
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    // 키체인에서 데이터를 불러오는 함수
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        } else {
            return nil
        }
    }
    
    // 키체인에서 데이터를 삭제하는 함수
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
