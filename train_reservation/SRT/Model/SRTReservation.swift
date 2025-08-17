import Foundation

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
