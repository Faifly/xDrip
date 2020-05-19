//
//  CustomSounds.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CustomSound: CaseIterable {
    case alarm
    case anticipate
    case bell
    case bloom
    case calypso
    case chime
    case chooChoo
    case descent
    case ding
    case electronic
    case fanfare
    case glass
    case horn
    case ladder
    case minuet
    case newsFlash
    case noir
    case sherwoodForest
    case spell
    case suspense
    case swish
    case swoosh
    case telegraph
    case tiptoes
    case tritone
    case typewriters
    
    var fileName: String {
        switch self {
        case .alarm: return "Alarm.caf"
        case .anticipate: return "Anticipate.caf"
        case .bell: return "Bell.caf"
        case .bloom: return "Bloom.caf"
        case .calypso: return "Calypso.caf"
        case .chime: return "Chime.caf"
        case .chooChoo: return "Choo_Choo.caf"
        case .descent: return "Descent.caf"
        case .ding: return "Ding.caf"
        case .electronic: return "Electronic.caf"
        case .fanfare: return "Fanfare.caf"
        case .glass: return "Glass.caf"
        case .horn: return "Horn.caf"
        case .ladder: return "Ladder.caf"
        case .minuet: return "Minuet.caf"
        case .newsFlash: return "News_Flash.caf"
        case .noir: return "Noir.caf"
        case .sherwoodForest: return "Sherwood_Forest.caf"
        case .spell: return "Spell.caf"
        case .suspense: return "Suspense.caf"
        case .swish: return "Swish.caf"
        case .swoosh: return "Swoosh.caf"
        case .telegraph: return "Telegraph.caf"
        case .tiptoes: return "Tiptoes.caf"
        case .tritone: return "Tri-tone.caf"
        case .typewriters: return "Typewriters.caf"
        }
    }
}
