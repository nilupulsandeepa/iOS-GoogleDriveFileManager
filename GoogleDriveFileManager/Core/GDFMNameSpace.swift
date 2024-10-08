//
//  GDFMNameSpace.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-03.
//

import Foundation

public struct GDFMNameSpace {
    public struct UserDefaultIdentifiers {
        public static let isAppFirstTime: String = "com.test.nsw.gdrive.GoogleDriveFileManager.userdefaults.isAppFirstTime"
        public static let googleAuthenticationCode: String = "com.test.nsw.gdrive.GoogleDriveFileManager.userdefaults.googleAuthenticationCode"
        public static let googleAPIKey: String = "com.test.nsw.gdrive.GoogleDriveFileManager.userdefaults.googleAPIKey"
    }
    
    public struct FileMimeType {
        public static let googleSheet: String = ""
        public static let googleDoc: String = ""
        public static let googleSlide: String = ""
    }
}
