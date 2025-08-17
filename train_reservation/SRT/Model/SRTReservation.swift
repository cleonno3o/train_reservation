import Foundation

// MARK: - SRTTicket (Nested for now, can be moved to its own file later)
struct SRTTicket: Codable {
    let car: String?
    let seat: String?
    let seatTypeCode: String?
    let seatType: String? // Derived
    let passengerTypeCode: String?
    let passengerType: String? // Derived
    let price: Int?
    let originalPrice: Int?
    let discount: Int?
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
        car = try container.decodeIfPresent(String.self, forKey: .car)
        seat = try container.decodeIfPresent(String.self, forKey: .seat)
        seatTypeCode = try container.decodeIfPresent(String.self, forKey: .seatTypeCode)
        passengerTypeCode = try container.decodeIfPresent(String.self, forKey: .passengerTypeCode)
        price = try container.decodeIfPresent(Int.self, forKey: .price)
        originalPrice = try container.decodeIfPresent(Int.self, forKey: .originalPrice)
        discount = try container.decodeIfPresent(Int.self, forKey: .discount)

        // Derived properties
        seatType = SRTTicket.SEAT_TYPE[seatTypeCode ?? ""]
        passengerType = SRTTicket.DISCOUNT_TYPE[passengerTypeCode ?? ""]
        isWaiting = (seat ?? "") == ""
    }

    static let SEAT_TYPE: [String: String] = [
        "1": "일반실",
        "2": "특실"
    ]

    static let DISCOUNT_TYPE: [String: String] = [
        "000": "어른/청소년", "101": "탄력운임기준할인", "105": "자유석 할인", "106": "입석 할인",
        "107": "역방향석 할인", "108": "출입구석 할인", "109": "가족석 일반전환 할인",
        "111": "구간별 특정운임", "112": "열차별 특정운임", "113": "구간별 비율할인(기준)",
        "114": "열차별 비율할인(기준)", "121": "공항직결 수색연결운임",
        "131": "구간별 특별할인(기준)", "132": "열차별 특별할인(기준)", "133": "기본 특별할인(기준)",
        "191": "정차역 할인", "192": "매체 할인", "201": "어린이", "202": "동반유아 할인",
        "204": "경로", "205": "1~3급 장애인", "206": "4~6급 장애인",
    ]
}

// MARK: - SRTReservation
struct SRTReservation: CustomStringConvertible {
    let reservationNumber: String
    let totalCost: Int
    let seatCount: Int

    let trainCode: String
    let trainName: String
    let trainNumber: String

    let depDate: String
    let depTime: String
    let depStationCode: String
    let depStationName: String

    let arrTime: String
    let arrStationCode: String
    let arrStationName: String

    let paymentDate: String?
    let paymentTime: String?
    let isPaid: Bool
    let isRunning: Bool
    let isWaiting: Bool

    var tickets: [SRTTicket] // Assuming tickets are always provided

    // Custom initializer to mimic Python's __init__
    init(trainData: [String: Any], payData: [String: Any], tickets: [SRTTicket]) {
        // Extracting from trainData
        self.reservationNumber = trainData["pnrNo"] as? String ?? ""
        self.totalCost = (trainData["rcvdAmt"] as? Int) ?? 0
        // seatCount: Python's `or` operator for `tkSpecNum` or `seatNum`
        let tkSpecNum = trainData["tkSpecNum"] as? String
        let seatNum = payData["seatNum"] as? String // Assuming seatNum is in payData based on Python's int(train.get("seatNum"))
        self.seatCount = Int(tkSpecNum ?? seatNum ?? "0") ?? 0

        self.trainCode = payData["stlbTrnClsfCd"] as? String ?? ""
        self.trainNumber = payData["trnNo"] as? String ?? ""

        self.depDate = payData["dptDt"] as? String ?? ""
        self.depTime = payData["dptTm"] as? String ?? ""
        self.depStationCode = payData["dptRsStnCd"] as? String ?? ""

        self.arrTime = payData["arvTm"] as? String ?? ""
        self.arrStationCode = payData["arvRsStnCd"] as? String ?? ""

        self.paymentDate = payData["iseLmtDt"] as? String
        self.paymentTime = payData["iseLmtTm"] as? String
        self.isPaid = (payData["stlFlg"] as? String) == "Y"

        // Derived properties using SRTConstant (assuming it's accessible)
        self.trainName = SRTConstant.TRAIN_NAME[self.trainCode] ?? "알 수 없음"
        self.depStationName = SRTConstant.STATION_NAME[self.depStationCode] ?? "알 수 없음"
        self.arrStationName = SRTConstant.STATION_NAME[self.arrStationCode] ?? "알 수 없음"

        // isRunning: Python's `"tkSpecNum" not in train`
        self.isRunning = (trainData["tkSpecNum"] as? String) == nil

        // isWaiting: Python's `not (self.paid or self.payment_date or self.payment_time)`
        self.isWaiting = !(self.isPaid || (self.paymentDate != nil) || (self.paymentTime != nil))

        self.tickets = tickets
    }

    // CustomStringConvertible 프로토콜 구현 (dump() 함수 역할)
    var description: String {
        let depHour = depTime.prefix(2)
        let depMin = depTime.suffix(4).prefix(2)
        let arrHour = arrTime.prefix(2)
        let arrMin = arrTime.suffix(4).prefix(2)

        let depTotalMinutes = (Int(depHour) ?? 0) * 60 + (Int(depMin) ?? 0)
        let arrTotalMinutes = (Int(arrHour) ?? 0) * 60 + (Int(arrMin) ?? 0)
        var duration = arrTotalMinutes - depTotalMinutes
        if duration < 0 {
            duration += 24 * 60
        }

        let month = depDate.suffix(4).prefix(2)
        let day = depDate.suffix(2)

        let base = """
        [\(trainName)] \(month)월 \(day)일, \(depStationName)~\(arrStationName)(\(depHour):\(depMin)~\(arrHour):\(arrMin)) \(totalCost)원(\(seatCount)석)
        """

        var additionalInfo = ""
        if !isPaid {
            if !isWaiting {
                if let paymentDate = paymentDate, let paymentTime = paymentTime {
                    let payMonth = paymentDate.suffix(4).prefix(2)
                    let payDay = paymentDate.suffix(2)
                    let payHour = paymentTime.prefix(2)
                    let payMin = paymentTime.suffix(4).prefix(2)
                    additionalInfo += ", 구입기한 \(payMonth)월 \(payDay)일 \(payHour):\(payMin)"
                }
            } else if !isRunning {
                additionalInfo += ", 예약대기"
            }
        }

        if isRunning {
            additionalInfo += " (운행중)"
        }

        return base + additionalInfo
    }
}