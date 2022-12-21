//
//  PaymentStatus.swift
//  FlightAppUI
//
//  Created by Seungchul Ha on 2022/12/21.
//

import SwiftUI

enum PaymentStatus: String, CaseIterable {
    case started = "Connected..."
    case inititated = "secure payment..."
    case finished = "Purchased"
    
    var symbolImage: String {
        switch self {
        case .started:
            return "wifi"
        case .inititated:
            return "checkmark.shield"
        case .finished:
            return "checkmark"
        }
    }
}
