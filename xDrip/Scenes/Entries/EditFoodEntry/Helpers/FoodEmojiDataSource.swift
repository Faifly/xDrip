//
//  FoodEmojiDataSource.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

class FoodEmojiDataSource: EmojiDataSource {
    private static let fast: [String] = {
        var fast = [
            "🍭", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍",
            "🍎", "🍏", "🍐", "🍑", "🍒", "🍓", "🥝",
            "🍅", "🥔", "🥕", "🌽", "🌶", "🥒", "🥗", "🍄",
            "🍞", "🥐", "🥖", "🥞", "🍿", "🍘", "🍙",
            "🍚", "🍢", "🍣", "🍡", "🍦", "🍧", "🍨",
            "🍩", "🍪", "🎂", "🍰", "🍫", "🍬", "🍮",
            "🍯", "🍼", "🥛", "☕️", "🍵",
            "🥥", "🥦", "🥨", "🥠", "🥧"
        ]

        return fast
    }()

    private static let medium: [String] = {
        var medium = [
            "🌮", "🍆", "🍟", "🍳", "🍲", "🍱", "🍛",
            "🍜", "🍠", "🍤", "🍥", "🍹",
            "🥪", "🥫", "🥟", "🥡"
        ]

        return medium
    }()

    private static let slow: [String] = {
        var slow = [
            "🍕", "🥑", "🥜", "🌰", "🧀", "🍖", "🍗", "🥓",
            "🍔", "🌭", "🌯", "🍝", "🥩"
        ]

        return slow
    }()

    private static let other: [String] = {
        var other = [
            "🍶", "🍾", "🍷", "🍸", "🍺", "🍻", "🥂", "🥃",
            "🥣", "🥤", "🥢",
            "1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣",
            "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟"
        ]

        return other
    }()

    let sections: [EmojiSection]

    init() {
        sections = [
            EmojiSection(
                title: "Fast",
                items: FoodEmojiDataSource.fast,
                indexSymbol: " 🍭 "
            ),
            EmojiSection(
                title: "Medium",
                items: FoodEmojiDataSource.medium,
                indexSymbol: "🌮"
            ),
            EmojiSection(
                title: "Slow",
                items: FoodEmojiDataSource.slow,
                indexSymbol: "🍕"
            ),
            EmojiSection(
                title: "Other",
                items: FoodEmojiDataSource.other,
                indexSymbol: "⋯ "
            )
        ]
    }
}
