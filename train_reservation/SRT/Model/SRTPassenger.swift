//
//  SRTPassenger.swift
//  train_reservation
//
//  Created by sumin on 8/18/25.
//

import Foundation

// MARK: - SRTPassenger Protocol
// Python의 Passenger 기본 클래스 역할을 하는 프로토콜
protocol SRTPassenger: CustomStringConvertible {
    var name: String { get }
    var typeCode: String { get }
    var count: Int { get set }
}

extension SRTPassenger {
    var description: String {
        return "\(name) \(count)명"
    }
}

// MARK: - Passenger Types
struct Adult: SRTPassenger {
    let name = "어른/청소년"
    let typeCode = "1"
    var count: Int
}

struct Child: SRTPassenger {
    let name = "어린이"
    let typeCode = "5"
    var count: Int
}

struct Senior: SRTPassenger {
    let name = "경로"
    let typeCode = "4"
    var count: Int
}

struct Disability1To3: SRTPassenger {
    let name = "장애 1~3급"
    let typeCode = "2"
    var count: Int
}

struct Disability4To6: SRTPassenger {
    let name = "장애 4~6급"
    let typeCode = "3"
    var count: Int
}


// MARK: - Array Extension for Passenger Utilities
// Python의 classmethod, staticmethod들을 대체하는 익스텐션
extension Array where Element == SRTPassenger {

    /// 여러 승객 배열을 종류별로 합칩니다. (Python의 combine 역할)
    /// 예: [Adult(1), Adult(1), Child(1)] -> [Adult(2), Child(1)]
    func combine() -> [SRTPassenger] {
        var combined = [ObjectIdentifier: SRTPassenger]()

        for passenger in self {
            let id = ObjectIdentifier(type(of: passenger))
            if var existing = combined[id] {
                existing.count += passenger.count
                combined[id] = existing
            } else {
                combined[id] = passenger
            }
        }
        return Array(combined.values).filter { $0.count > 0 }
    }

    /// 배열에 포함된 모든 승객의 총 수를 문자열로 반환합니다. (Python의 total_count 역할)
    func totalCount() -> String {
        return String(self.reduce(0) { $0 + $1.count })
    }

    /// SRT 예약 API 요청에 필요한 파라미터 딕셔너리를 생성합니다. (Python의 get_passenger_dict 역할)
    func getPassengerDict(isSpecialSeat: Bool) -> [String: String] {
        let combinedPassengers = self.combine()
        
        var data: [String: String] = [
            "totPrnb": combinedPassengers.totalCount(),
            "psgGridcnt": String(combinedPassengers.count),
            "locSeatAttCd1": "000", // 창가/복도 미지정
            "rqSeatAttCd1": "015", // 일반
            "dirSeatAttCd1": "009",
            "smkSeatAttCd1": "000",
            "etcSeatAttCd1": "000",
            "psrmClCd1": isSpecialSeat ? "2" : "1" // 2: 특실, 1: 일반실
        ]

        for (index, passenger) in combinedPassengers.enumerated() {
            let i = index + 1
            data["psgTpCd\(i)"] = passenger.typeCode
            data["psgInfoPerPrnb\(i)"] = String(passenger.count)
        }
        
        return data
    }
}
