//
//  SRTTrain.swift
//  train_reservation
//
//  Created by Gemini on 8/16/25.
//

import Foundation
import SwiftUI

// SRT 열차 정보를 담을 구조체 (srt.py의 SRTTrain 클래스 참고)
struct SRTTrain: Codable, Identifiable {
    let id = UUID() // SwiftUI List에서 Identifiable을 위해 필요
    let trainCode: String
    let trainName: String
    let trainNumber: String
    
    let depDate: String
    let depTime: String
    let depStationCode: String
    let depStationName: String
    
    let arrDate: String
    let arrTime: String
    let arrStationCode: String
    let arrStationName: String
    
    let generalSeatState: String // 일반실 좌석 상태 (예: "예약가능", "매진")
    let specialSeatState: String // 특실 좌석 상태
    
    // Codable 키 매핑 (JSON 키와 Swift 속성 이름이 다를 경우)
    enum CodingKeys: String, CodingKey {
        case trainCode = "stlbTrnClsfCd"
        case trainName = "stlbTrnClsfCdNm" // srt.py에서는 TRAIN_NAME 딕셔너리 사용
        case trainNumber = "trnNo"
        
        case depDate = "dptDt"
        case depTime = "dptTm"
        case depStationCode = "dptRsStnCd"
        case depStationName = "dptRsStnCdNm"
        
        case arrDate = "arvDt"
        case arrTime = "arvTm"
        case arrStationCode = "arvRsStnCd"
        case arrStationName = "arvRsStnCdNm"
        
        case generalSeatState = "gnrmRsvPsbStr"
        case specialSeatState = "sprmRsvPsbStr"
    }
    
    // 편의를 위한 초기화 (JSON 파싱 시 사용)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trainCode = try container.decode(String.self, forKey: .trainCode)
        trainName = try container.decode(String.self, forKey: .trainName)
        trainNumber = try container.decode(String.self, forKey: .trainNumber)
        
        depDate = try container.decode(String.self, forKey: .depDate)
        depTime = try container.decode(String.self, forKey: .depTime)
        depStationCode = try container.decode(String.self, forKey: .depStationCode)
        depStationName = try container.decode(String.self, forKey: .depStationName)
        
        arrDate = try container.decode(String.self, forKey: .arrDate)
        arrTime = try container.decode(String.self, forKey: .arrTime)
        arrStationCode = try container.decode(String.self, forKey: .arrStationCode)
        arrStationName = try container.decode(String.self, forKey: .arrStationName)
        
        generalSeatState = try container.decode(String.self, forKey: .generalSeatState)
        specialSeatState = try container.decode(String.self, forKey: .specialSeatState)
    }
}
