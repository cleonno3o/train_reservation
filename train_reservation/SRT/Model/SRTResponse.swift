//
//  SRTResponseModel.swift
//  train_reservation
//
//  Created by sumin on 8/16/25.
//

import Foundation

// Top-level response structure
struct SRTFullAPIResponse: Codable {
    let errorMsg: String
    let errorCode: String
    let resultMap: [ResultMapEntry]
    let outDataSets: SRTResponseDataSet
    let commandMap: CommandMapData
    let trainListMap: [SRTTrain]

    enum CodingKeys: String, CodingKey {
        case errorMsg = "ErrorMsg"
        case errorCode = "ErrorCode"
        case resultMap
        case outDataSets
        case commandMap
        case trainListMap
    }
}

// Struct for items in resultMap
struct ResultMapEntry: Codable {
    let msgCd: String
    let seandYo: String
    let wctNo: String
    let qryCnqeCnt: Int
    let strResult: String
    let msgTxt: String
    let fllwPgExt2: String?
    let fllwPgExt: String
    let uuid: String
    let cgPsId: String
}

// Existing SRTResponseDataSet (already defined)
struct SRTResponseDataSet: Codable {
    let dsOutput1: [SRTTrain]
    // 다른 dsOutputX가 있다면 여기에 추가
    
    enum CodingKeys: String, CodingKey {
        case dsOutput1 = "dsOutput1"
    }
}

// Struct for commandMap
struct CommandMapData: Codable {
    let chtnDvCd: String
    let dptDt: String
    let dptTm: String
    let dptDt1: String
    let dptTm1: String
    let dptRsStnCd: String
    let arvRsStnCd: String
    let stlbTrnClsfCd: String
    let trnGpCd: String
    let trnNo: String
    let psgNum: String
    let seatAttCd: String
    let arriveTime: String
    let tkDptDt: String
    let tkDptTm: String
    let tkTrnNo: String
    let tkTripChgFlg: String
    let dlayTnumAplFlg: String
    let netfunnelKey: String
}