//
//  GDFMAuthenticationViewController.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-04.
//

import UIKit

public class GDFMAuthenticationViewController: UIViewController {
    
}

extension GDFMAuthenticationViewController: GDFMAuthenticationDelegate {
    public func didReceiveAuthorizationCode(code: String) {
        GDFMUserDefaultManager.shared.googleAuthenticationCode = code
    }
    
    public func didReceiveAPIKey(key: String) {
        GDFMUserDefaultManager.shared.googleAPIKey = key
    }
}
