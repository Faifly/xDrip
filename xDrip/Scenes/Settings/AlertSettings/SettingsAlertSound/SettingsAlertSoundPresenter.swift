//
//  SettingsAlertSoundPresenter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsAlertSoundPresentationLogic {
    func presentLoad(response: SettingsAlertSound.Load.Response)
}

final class SettingsAlertSoundPresenter: SettingsAlertSoundPresentationLogic {
    weak var viewController: SettingsAlertSoundDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsAlertSound.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(sections: [
            createSoundsSection(response: response)
        ])
        
        
        let viewModel = SettingsAlertSound.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    private func createSoundsSection(response: SettingsAlertSound.Load.Response) -> BaseSettings.Section {
        let sounds = CustomSound.allCases.map({ $0.title })
        
        return .singleSelection(
            cells: sounds,
            selectedIndex: response.selectedIndex,
            header: "settings_alert_sound_section_header".localized,
            footer: nil,
            selectionHandler: response.singleSelectionHandler
        )
    }
}

private extension CustomSound {
    var title: String {
        switch self {
        case .alarm: return "settings_alert_sound_alarm".localized
        case .anticipate: return "settings_alert_sound_anticipate".localized
        case .bell: return "settings_alert_sound_bell".localized
        case .bloom: return "settings_alert_sound_bloom".localized
        case .calypso: return "settings_alert_sound_calypso".localized
        case .chime: return "settings_alert_sound_chime".localized
        case .chooChoo: return "settings_alert_sound_choo_choo".localized
        case .descent: return "settings_alert_sound_descent".localized
        case .ding: return "settings_alert_sound_ding".localized
        case .electronic: return "settings_alert_sound_electronic".localized
        case .fanfare: return "settings_alert_sound_fanfare".localized
        case .glass: return "settings_alert_sound_glass".localized
        case .horn: return "settings_alert_sound_horn".localized
        case .ladder: return "settings_alert_sound_ladder".localized
        case .minuet: return "settings_alert_sound_minuet".localized
        case .newsFlash: return "settings_alert_sound_news_flash".localized
        case .noir: return "settings_alert_sound_noir".localized
        case .sherwoodForrest: return "settings_alert_sound_sheerwood_forrest".localized
        case .spell: return "settings_alert_sound_spell".localized
        case .suspense: return "settings_alert_sound_suspense".localized
        case .swish: return "settings_alert_sound_swish".localized
        case .swoosh: return "settings_alert_sound_swoosh".localized
        case .telegraph: return "settings_alert_sound_telegraph".localized
        case .tiptoes: return "settings_alert_sound_tiptoes".localized
        case .tritone: return "settings_alert_sound_tri-tone".localized
        case .typewriters: return "settings_alert_sound_typewriters".localized
        }
    }
}
