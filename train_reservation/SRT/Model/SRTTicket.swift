//
//  SRTTicket.swift
//  train_reservation
//
//  Created by 주수민 on 8/17/25.
//

import Foundation

// MARK: - SRTTicket (Nested for now, can be moved to its own file later)
struct SRTTicket: Codable {
    let car: String
    let seat: String
    let seatTypeCode: String
    let seatType: String // Derived
    let passengerTypeCode: String
    let passengerType: String // Derived
    let price: Int
    let originalPrice: Int
    let discount: Int
    let isWaiting: Bool // Derived

    enum CodingKeys: String, CodingKey {
        case car = "scarNo"
        case seat = "seatNo"
        case seatTypeCode = "psrmClCd"
        case passengerTypeCode = "dcntKndCd"
        case price = "rcvdAmt"
        case originalPrice = "stdrPrc"
        case discount = "dcntPrc"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        car = try container.decode(String.self, forKey: .car)
        seat = try container.decode(String.self, forKey: .seat)
        seatTypeCode = try container.decode(String.self, forKey: .seatTypeCode)
        passengerTypeCode = try container.decode(String.self, forKey: .passengerTypeCode)
        price = try container.decode(Int.self, forKey: .price)
        originalPrice = try container.decode(Int.self, forKey: .originalPrice)
        discount = try container.decode(Int.self, forKey: .discount)

        // Derived properties
        seatType = SRTConstant.SEAT_TYPE[self.seatTypeCode] ?? ""
        passengerType = SRTConstant.PASSENGER_TYPE[self.passengerTypeCode] ?? ""
        isWaiting = self.seat == ""
    }
}
