//
//  FoodEmojiDataSource.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class FoodEmojiDataSource {
    struct EmojiSection {
        let title: String
        let items: [String]
    }
    
    private static let fast: [String] = [
        "🍭", "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍",
        "🍎", "🍏", "🍐", "🍑", "🍒", "🍓", "🥝",
        "🍅", "🥔", "🥕", "🌽", "🌶", "🥒", "🥗", "🍄",
        "🍞", "🥐", "🥖", "🥞", "🍿", "🍘", "🍙",
        "🍚", "🍢", "🍣", "🍡", "🍦", "🍧", "🍨",
        "🍩", "🍪", "🎂", "🍰", "🍫", "🍬", "🍮",
        "🍯", "🍼", "🥛", "☕️", "🍵",
        "🥥", "🥦", "🥨", "🥠", "🥧"
    ]

    private static let medium: [String] = [
        "🌮", "🍆", "🍟", "🍳", "🍲", "🍱", "🍛",
        "🍜", "🍠", "🍤", "🍥", "🍹",
        "🥪", "🥫", "🥟", "🥡"
    ]

    private static let slow: [String] = [
        "🍕", "🥑", "🥜", "🌰", "🧀", "🍖", "🍗", "🥓",
        "🍔", "🌭", "🌯", "🍝", "🥩"
    ]

    private static let other: [String] = [
        "🍶", "🍾", "🍷", "🍸", "🍺", "🍻", "🥂", "🥃",
        "🥣", "🥤", "🥢",
        "1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣",
        "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟"
    ]

    let sections: [EmojiSection]
    
    init() {
        sections = [
            EmojiSection(
                title: "edit_entry_fast_carbs_title".localized,
                items: FoodEmojiDataSource.fast
            ),
            EmojiSection(
                title: "edit_entry_medium_carbs_title".localized,
                items: FoodEmojiDataSource.medium
            ),
            EmojiSection(
                title: "edit_entry_slow_carbs_title".localized,
                items: FoodEmojiDataSource.slow
            ),
            EmojiSection(
                title: "edit_entry_other_carbs_title".localized,
                items: FoodEmojiDataSource.other
            )
        ]
    }
}
