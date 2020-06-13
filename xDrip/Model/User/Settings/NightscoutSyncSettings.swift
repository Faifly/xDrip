//
//  NightscoutSyncSettings.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class NightscoutSyncSettings: Object {
    @objc private(set) dynamic var isEnabled: Bool = false
    @objc private(set) dynamic var useCellularData: Bool = true
    @objc private(set) dynamic var sendDisplayGlucose: Bool = false
    @objc private(set) dynamic var baseURL: String?
    @objc private(set) dynamic var downloadData: Bool = false
    @objc private(set) dynamic var automaticCalibration: Bool = false
    @objc private(set) dynamic var skipLANUploads: Bool = true
    @objc private(set) dynamic var uploadBridgeBattery: Bool = false
    @objc private(set) dynamic var uploadTreatments: Bool = false
    @objc private(set) dynamic var alertOnFailures: Bool = false
    @objc private(set) dynamic var appendSourceInfoToDevices: Bool = false
    @objc private(set) dynamic var apiSecret: String?
    @objc private(set) dynamic var isFollowerAuthed: Bool = false
    
    var inReadonlyFollowerMode: Bool {
        return isFollowerAuthed && !String.isEmpty(apiSecret)
    }
    
    func updateIsEnabled(_ isEnabled: Bool) {
        Realm.shared.safeWrite {
            self.isEnabled = isEnabled
        }
    }
    
    func updateUseCellularData(_ use: Bool) {
        Realm.shared.safeWrite {
            self.useCellularData = use
        }
    }
    
    func updateSendDisplayGlucose(_ send: Bool) {
        Realm.shared.safeWrite {
            self.sendDisplayGlucose = send
        }
    }
    
    func updateBaseURL(_ url: String?) {
        Realm.shared.safeWrite {
            self.baseURL = url
        }
    }
    
    func updateDownloadData(_ download: Bool) {
        Realm.shared.safeWrite {
            self.downloadData = download
        }
    }
    
    func updateAutomaticCalibration(_ autoCalibration: Bool) {
        Realm.shared.safeWrite {
            self.automaticCalibration = autoCalibration
        }
    }
    
    func updateSkipLANUploads(_ skip: Bool) {
        Realm.shared.safeWrite {
            self.skipLANUploads = skip
        }
    }
    
    func updateUploadBridgeBattery(_ upload: Bool) {
        Realm.shared.safeWrite {
            self.uploadBridgeBattery = upload
        }
    }
    
    func updateUploadTreatments(_ upload: Bool) {
        Realm.shared.safeWrite {
            self.uploadTreatments = upload
        }
    }
    
    func updateAlertOnFailures(_ alert: Bool) {
        Realm.shared.safeWrite {
            self.alertOnFailures = alert
        }
    }
    
    func updateAppendSourceInfoToDevices(_ append: Bool) {
        Realm.shared.safeWrite {
            self.appendSourceInfoToDevices = append
        }
    }
    
    func updateAPISecret(_ secret: String?) {
        Realm.shared.safeWrite {
            self.apiSecret = secret
        }
    }
    
    func updateIsFollowerAuthed(_ authed: Bool) {
        Realm.shared.safeWrite {
            self.isFollowerAuthed = authed
        }
        NotificationCenter.default.postSettingsChangeNotification(setting: .followerAuthStatus)
    }
}
