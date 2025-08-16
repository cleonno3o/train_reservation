//
//  SRTTrain.swift
//  train_reservation
//
//  Created by sumin on 8/16/25.
//

import Foundation
import SwiftUI

// SRT 열차 정보를 담을 구조체 (srt.py의 SRTTrain 클래스 참고)
struct SRTTrain: Codable, Identifiable, CustomStringConvertible, Hashable, Equatable { // CustomStringConvertible, Hashable, Equatable 추가
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
    let reservePossibleName: String
    let reservePossibleCode: String // -1: 예약대기 없음, 9: 예약대기 가능, 0: 매진, -2: 예약대기 불가능
    
    // Codable 키 매핑 (JSON 키와 Swift 속성 이름이 다를 경우)
    enum CodingKeys: String, CodingKey {
        // 열차 정보
        case trainCode = "stlbTrnClsfCd"
        case trainNumber = "trnNo"
        
        // 출발 정보
        case depDate = "dptDt"
        case depTime = "dptTm"
        case depStationCode = "dptRsStnCd"
        
        // 도착 정보
        case arrDate = "arvDt"
        case arrTime = "arvTm"
        case arrStationCode = "arvRsStnCd"
        
        // 좌석 정보
        case generalSeatState = "gnrmRsvPsbStr"
        case specialSeatState = "sprmRsvPsbStr"
        case reservePossibleName = "rsvWaitPsbCdNm"
        case reservePossibleCode = "rsvWaitPsbCd"
    }
    
    // 편의를 위한 초기화 (JSON 파싱 시 사용)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // JSON에서 직접 디코딩하는 속성들
//        id = UUID() // Identifiable을 위해 필요
        trainCode = try container.decode(String.self, forKey: .trainCode)
        trainNumber = try container.decode(String.self, forKey: .trainNumber)
        
        depDate = try container.decode(String.self, forKey: .depDate)
        depTime = try container.decode(String.self, forKey: .depTime)
        depStationCode = try container.decode(String.self, forKey: .depStationCode)
        
        arrDate = try container.decode(String.self, forKey: .arrDate)
        arrTime = try container.decode(String.self, forKey: .arrTime)
        arrStationCode = try container.decode(String.self, forKey: .arrStationCode)
        
        generalSeatState = try container.decode(String.self, forKey: .generalSeatState)
        specialSeatState = try container.decode(String.self, forKey: .specialSeatState)
        reservePossibleName = try container.decode(String.self, forKey: .reservePossibleName)
        reservePossibleCode = try container.decode(String.self, forKey: .reservePossibleCode)
        
        // SRTConstant에서 조회하여 할당하는 속성들
        trainName = SRTConstant.TRAIN_NAME[trainCode] ?? "알 수 없음"
        depStationName = SRTConstant.STATION_NAME[depStationCode] ?? "알 수 없음"
        arrStationName = SRTConstant.STATION_NAME[arrStationCode] ?? "알 수 없음"
    }

    // CustomStringConvertible 프로토콜 구현
    var description: String {
        let depHour = depTime.prefix(2)
        let depMin = depTime.suffix(4).prefix(2) // HHMMSS -> MM
        let arrHour = arrTime.prefix(2)
        let arrMin = arrTime.suffix(4).prefix(2) // HHMMSS -> MM

        // 시간 차이 계산 (분 단위)
        let depTotalMinutes = (Int(depHour) ?? 0) * 60 + (Int(depMin) ?? 0)
        let arrTotalMinutes = (Int(arrHour) ?? 0) * 60 + (Int(arrMin) ?? 0)
        var duration = arrTotalMinutes - depTotalMinutes
        if duration < 0 { // 자정을 넘어가면 24시간 추가
            duration += 24 * 60
        }

        let month = depDate.suffix(4).prefix(2)
        let day = depDate.suffix(2)

        let trainLine = "[" + trainName + " " + trainNumber + "]"

        return "\(trainLine) \(month)/\(day) \(depHour):\(depMin)~\(arrHour):\(arrMin) \(depStationName)~\(arrStationName) 특실 \(specialSeatState), 일반실 \(generalSeatState) (\(duration)분)"
    }

    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(trainCode)
        hasher.combine(trainNumber)
        hasher.combine(depDate)
        hasher.combine(depTime)
        hasher.combine(depStationCode)
        hasher.combine(arrDate)
        hasher.combine(arrTime)
        hasher.combine(arrStationCode)
    }

    // MARK: - Equatable Conformance
    static func == (lhs: SRTTrain, rhs: SRTTrain) -> Bool {
        return lhs.trainCode == rhs.trainCode &&
               lhs.trainNumber == rhs.trainNumber &&
               lhs.depDate == rhs.depDate &&
               lhs.depTime == rhs.depTime &&
               lhs.depStationCode == rhs.depStationCode &&
               lhs.arrDate == rhs.arrDate &&
               lhs.arrTime == rhs.arrTime &&
               lhs.arrStationCode == rhs.arrStationCode
    }
}
