//
//  SettingBundleReader.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 23/10/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import Foundation
class SettingsBundleHelper {
    struct SettingBundleKeys {
        static let Reset = "RESET_APP_KEY"
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
        static let RedThemeKey = "red_theme_key"
        static let BundleShortVersion = "CFBundleShortVersionString"
        static let BundleVersion = "CFBundleVersion"
    }
    class func checkAndExecuteSettings() {
        if UserDefaults.standard.bool(forKey: SettingBundleKeys.Reset) {
            UserDefaults.standard.set(false, forKey: SettingBundleKeys.Reset)
            let appDomain: String? = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        }
    }
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey:  SettingBundleKeys.BundleShortVersion) as! String //CFBundleShortVersionString
        UserDefaults.standard.set(version, forKey:  SettingBundleKeys.AppVersionKey)
        let build: String = Bundle.main.object(forInfoDictionaryKey: SettingBundleKeys.BundleVersion) as! String
        UserDefaults.standard.set(build, forKey: SettingBundleKeys.BuildVersionKey )
    }
    
}
