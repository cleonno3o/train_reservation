//
//  SRTSeatPreference.swift
//  train_reservation
//
//  Created by sumin on 8/17/25.
//

enum SeatPreference: String, CaseIterable, Identifiable {
    case generalFirst = "일반실 우선"
    case generalOnly = "일반실만"
    case specialFirst = "특실 우선"
    case specialOnly = "특실만"

    var id: Self { self }
}
