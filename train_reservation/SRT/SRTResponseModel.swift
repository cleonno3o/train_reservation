//
//  SRTResponseModel.swift
//  train_reservation
//
//  Created by Gemini on 8/16/25.
//

import Foundation

// SRT API 응답 데이터 구조 (srt.py의 SRTResponseData 참고)
struct SRTResponseDataSet: Codable {
    let dsOutput1: [SRTTrain]
    // 다른 dsOutputX가 있다면 여기에 추가
    
    enum CodingKeys: String, CodingKey {
        case dsOutput1 = "dsOutput1"
    }
}
