//
//  GDFMAuthenticationViewController.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-04.
//

import UIKit

public class GDFMAuthenticationViewController: UIViewController {
    public override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = .red
//        GDFMUserDefaultManager.shared.googleAPIKey = "_none"
        if (GDFMUserDefaultManager.shared.googleAPIKey != "_none") {
            GDFMDriveDocumentManager.shared.delegate = self
            GDFMDriveDocumentManager.shared.getListOfFilesFromDrive(apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
        } else {
            GDFMAuthenticationManager.shared.setPresentationAnchor(view.window!)
            GDFMAuthenticationManager.shared.delegate = self
            GDFMAuthenticationManager.shared.initializeAuthSession()
        }
    }
    
    private func authorizationSuccess(code: String) {
        GDFMUserDefaultManager.shared.googleAuthenticationCode = code
        GDFMAuthenticationManager.shared.requestAPIKey(authCode: code)
    }
    
    private func apiKeyReceived(key: String) {
        GDFMUserDefaultManager.shared.googleAPIKey = key
    }
}

extension GDFMAuthenticationViewController: GDFMAuthenticationDelegate {
    public func didReceiveAuthorizationCode(code: String) {
        authorizationSuccess(code: code)
    }
    
    public func didReceiveAPIKey(key: String) {
        apiKeyReceived(key: key)
        GDFMDriveDocumentManager.shared.delegate = self
        GDFMDriveDocumentManager.shared.getListOfFilesFromDrive(apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
    }
}

extension GDFMAuthenticationViewController: GDFMDriveDocumentManagerDelegate {
    public func onReceiveFileList(list: [GDFMDriveFile]) {
        GDFMDriveDocumentManager.shared.downloadFileFromDrive(file: list.first!, apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
    }
    
    public func onFileDownloadComplete(tempURL: URL, fileName: String) {
        GDFMLocalFileManager.shared.moveFileIntoDocumentsFolder(sourceURL: tempURL, fileName: fileName)
    }
}
