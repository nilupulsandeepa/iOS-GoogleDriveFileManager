//
//  GDFMUserDefaultManager.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-03.
//

import Foundation

public class GDFMUserDefaultManager {
    public static var shared: GDFMUserDefaultManager = GDFMUserDefaultManager()
    
    public var isAppFirstTime: Bool {
        get {
            return UserDefaults.standard.value(forKey: GDFMNameSpace.UserDefaultIdentifiers.isAppFirstTime) as? Bool ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: GDFMNameSpace.UserDefaultIdentifiers.isAppFirstTime)
        }
    }
    
    public var googleAuthenticationCode: String {
        get {
            return UserDefaults.standard.value(forKey: GDFMNameSpace.UserDefaultIdentifiers.googleAuthenticationCode) as? String ?? "_none"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: GDFMNameSpace.UserDefaultIdentifiers.googleAuthenticationCode)
        }
    }
    
    public var googleAPIKey: String {
        get {
            return UserDefaults.standard.value(forKey: GDFMNameSpace.UserDefaultIdentifiers.googleAPIKey) as? String ?? "_none"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: GDFMNameSpace.UserDefaultIdentifiers.googleAPIKey)
        }
    }
}
