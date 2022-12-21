//
//  Card.swift
//  FlightAppUI
//
//  Created by Seungchul Ha on 2022/12/20.
//

import SwiftUI

// MARK: Card Model And Sample Cards
struct Card: Identifiable {
    var id: UUID = .init()
    var cardImage: String
    
    /// Other Properties
}

var sampleCards: [Card] = [
    .init(cardImage: "Card1"),
    .init(cardImage: "Card2"),
    .init(cardImage: "Card3"),
    .init(cardImage: "Card4"),
    .init(cardImage: "Card5"),
    .init(cardImage: "Card6"),
    .init(cardImage: "Card7"),
    .init(cardImage: "Card8"),
    .init(cardImage: "Card9"),
    .init(cardImage: "Card10")
]
