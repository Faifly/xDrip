//
//  EmojiDataSource.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

struct EmojiSection {
    let title: String
    let items: [String]
    let indexSymbol: String
}

protocol EmojiDataSource {
    var sections: [EmojiSection] { get }
}
