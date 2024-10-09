//
//  GDFMAuthenticationViewController.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-04.
//

import UIKit

public class GDFMAuthenticationViewController: UIViewController {
    
    public override func viewDidLoad() {
        view.addSubview(g_AuthenticationView)
        g_AuthenticationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        g_AuthenticationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        g_AuthenticationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        g_AuthenticationView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if (GDFMUserDefaultManager.shared.isAppFirstTime) {
            g_AuthenticationView.showGoogleSignInView()
        } else {
//            g_AuthenticationView.startActivityIndicatorAnimation()
        }
//        GDFMUserDefaultManager.shared.googleAPIKey = "_none"
//        if (GDFMUserDefaultManager.shared.googleAPIKey != "_none") {
//            GDFMDriveDocumentManager.shared.delegate = self
//            GDFMDriveDocumentManager.shared.getListOfFilesFromDrive(apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
//        } else {
//            GDFMAuthenticationManager.shared.setPresentationAnchor(view.window!)
//            GDFMAuthenticationManager.shared.delegate = self
//            GDFMAuthenticationManager.shared.initializeAuthSession()
//        }
    }
    
    //---- MARK: Helper Methods
    private func startGoogleSignInProcess() {
        g_AuthenticationView.showLoadingView()
        g_AuthenticationView.startActivityIndicatorAnimation()
        g_AuthenticationView.changeActivityStatusLabelText(text: "Logging In...")
        //---- Intentional Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            GDFMAuthenticationManager.shared.setPresentationAnchor(self.view.window!)
            GDFMAuthenticationManager.shared.delegate = self
            GDFMAuthenticationManager.shared.initializeAuthSession()
        })
    }
    
    private func authorizationSuccess(code: String) {
        GDFMUserDefaultManager.shared.googleAuthenticationCode = code
        GDFMAuthenticationManager.shared.requestAPIKey(authCode: code)
    }
    
    private func authorizationFailed() {
        g_AuthenticationView.changeActivityStatusLabelText(text: "Google signin failed!")
        g_AuthenticationView.stopActivityIndicatorAnimation()
        //---- Intentional Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.g_AuthenticationView.showGoogleSignInView()
        })
    }
    
    private func apiKeyReceived(key: String) {
        GDFMUserDefaultManager.shared.googleAPIKey = key
    }
    
    //---- MARK: UI Components
    private lazy var g_AuthenticationView: GDFMAuthenticationView = {
        let m_View: GDFMAuthenticationView = GDFMAuthenticationView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.delegate = self
        
        return m_View
    }()
}

extension GDFMAuthenticationViewController: GDFMAuthenticationViewDelegate {
    public func onGoogleSignInButtonTap() {
        startGoogleSignInProcess()
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
    
    public func onAuthorizationFail() {
        authorizationFailed()
    }
}

extension GDFMAuthenticationViewController: GDFMDriveDocumentManagerDelegate {
    public func onReceiveFileList(list: [GDFMDriveFile]) {
        for file in list {
            GDFMDriveDocumentManager.shared.downloadFileFromDrive(file: file, apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
        }
    }
    
    public func onFileDownloadComplete(tempURL: URL, fileName: String) {
        GDFMLocalFileManager.shared.moveFileIntoDocumentsFolder(sourceURL: tempURL, fileName: fileName)
    }
    
    public func onFileUploadComplete() {
        print("File Uploaded")
    }
}
