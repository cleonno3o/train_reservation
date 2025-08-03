//
//  SRTConstants.swift
//  train_reservation
//
//  Created by Gemini on 8/3/25.
//

import Foundation

// srt.py에서 추출한 SRT 관련 상수들을 모아둔 구조체
struct SRTConstants {
    // User-Agent 문자열
    static let USER_AGENT = "Mozilla/5.0 (Linux; Android 14; SM-S912N Build/UP1A.231005.007; wv) AppleWebKit/537.36(KHTML, like Gecko) Version/4.0 Chrome/131.0.6778.260 Mobile Safari/537.36SRT-APP-Android V.2.0.33"
    
    // 기본 HTTP 헤더
    static let DEFAULT_HEADERS: [String: String] = [
        "User-Agent": USER_AGENT,
        "Accept": "application/json",
    ]
    
    // 역 코드 딕셔너리 (역 이름: 역 코드)
    static let STATION_CODE: [String: String] = [
        "수서": "0551",
        "동탄": "0552",
        "평택지제": "0553",
        "경주": "0508",
        "곡성": "0049",
        "공주": "0514",
        "광주송정": "0036",
        "구례구": "0050",
        "김천(구미)": "0507",
        "나주": "0037",
        "남원": "0048",
        "대전": "0010",
        "동대구": "0015",
        "마산": "0059",
        "목포": "0041",
        "밀양": "0017",
        "부산": "0020",
        "서대구": "0506",
        "순천": "0051",
        "여수EXPO": "0053",
        "여천": "0139",
        "오송": "0297",
        "울산(통도사)": "0509",
        "익산": "0030",
        "전주": "0045",
        "정읍": "0033",
        "진영": "0056",
        "진주": "0063",
        "창원": "0057",
        "창원중앙": "0512",
        "천안아산": "0502",
        "포항": "0515",
    ]
    
    // 역 이름 딕셔너리 (역 코드: 역 이름)
    static let STATION_NAME: [String: String] = {
        var tempDict: [String: String] = [:]
        for (name, code) in STATION_CODE {
            tempDict[code] = name
        }
        return tempDict
    }()
    
    // 열차 이름 딕셔너리 (열차 코드: 열차 이름)
    static let TRAIN_NAME: [String: String] = [
        "00": "KTX",
        "02": "무궁화",
        "03": "통근열차",
        "04": "누리로",
        "05": "전체",
        "07": "KTX-산천",
        "08": "ITX-새마을",
        "09": "ITX-청춘",
        "10": "KTX-산천",
        "17": "SRT",
        "18": "ITX-마음",
    ]
    
    // SRT 모바일 기본 URL
    static let SRT_MOBILE = "https://app.srail.or.kr:443"
    
    // API 엔드포인트 딕셔너리
    static let API_ENDPOINTS: [String: String] = [
        "main": "\(SRT_MOBILE)/main/main.do",
        "login": "\(SRT_MOBILE)/apb/selectListApb01080_n.do",
        "logout": "\(SRT_MOBILE)/login/loginOut.do",
        "search_schedule": "\(SRT_MOBILE)/ara/selectListAra10007_n.do",
        "reserve": "\(SRT_MOBILE)/arc/selectListArc05013_n.do",
        "tickets": "\(SRT_MOBILE)/atc/selectListAtc14016_n.do",
        "ticket_info": "\(SRT_MOBILE)/ard/selectListArd02019_n.do",
        "cancel": "\(SRT_MOBILE)/ard/selectListArd02045_n.do",
        "standby_option": "\(SRT_MOBILE)/ata/selectListAta01135_n.do",
        "payment": "\(SRT_MOBILE)/ata/selectListAta09036_n.do",
        "reserve_info": "\(SRT_MOBILE)/atc/getListAtc14087.do",
        "reserve_info_referer": "\(SRT_MOBILE)/common/ATC/ATC0201L/view.do?pnrNo=",
        "refund": "\(SRT_MOBILE)/atc/selectListAtc02063_n.do",
    ]
}
