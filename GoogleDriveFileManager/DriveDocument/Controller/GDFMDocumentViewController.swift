//
//  GDFMDocumentViewController.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-07.
//

import UIKit

public class GDFMDocumentViewController: UIViewController {
    public override func viewDidLoad() {
        view.backgroundColor = .darkGray
        GDFMDriveDocumentManager.shared.delegate = self
        configureUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if (GDFMUserDefaultManager.shared.isAppFirstTime) {
            showAuthenticationViewController()
            GDFMUserDefaultManager.shared.isAppFirstTime = false
        } else {
            if (GDFMUserDefaultManager.shared.googleAPIKey != "_none") {
                checkPermisionByFetchingDriveFileList()
            } else {
                showAuthenticationViewController()
            }
        }
    }
    
    //---- Helper Methods
    private func configureUI() {
        view.addSubview(g_DocumentView)
        g_DocumentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        g_DocumentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        g_DocumentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        g_DocumentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func showAuthenticationViewController() {
        let m_AuthenticationViewController: GDFMAuthenticationViewController = GDFMAuthenticationViewController()
        m_AuthenticationViewController.modalPresentationStyle = .overFullScreen
        m_AuthenticationViewController.documentViewDelegate = self
        present(m_AuthenticationViewController, animated: false)
    }
    
    private func checkPermisionByFetchingDriveFileList() {
        g_DocumentView.startActivityIndicatorAnimation()
        g_DocumentView.changeActivityStatusLabelText(text: "Fetching Files...")
        GDFMDriveDocumentManager.shared.getListOfFilesFromDrive(apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
    }
    
    private func fetchDriveFileList() {
        if (GDFMUserDefaultManager.shared.googleAPIKey != "_none") {
            g_DocumentView.startActivityIndicatorAnimation()
            g_DocumentView.changeActivityStatusLabelText(text: "Fetching Files...")
            GDFMDriveDocumentManager.shared.getListOfFilesFromDrive(apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
        }
    }
    
    private func didReceivedDriveFileList(list: [GDFMDriveFile]) {
        GDFMDriveDocumentManager.shared.setListOfFiles(list)
        g_DocumentView.stopActivityIndicatorAnimation()
        g_DocumentView.changeActivityStatusLabelText(text: "Files Received!")
    }
    
    private func handlePermisionFailed() {
        g_DocumentView.changeActivityStatusLabelText(text: "Permision Failed...")
        //Intentional Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.showAuthenticationViewController()
        })
    }
    
    //---- MARK: UI Components
    private lazy var g_DocumentView: GDFMDriveDocumentView = {
        let m_View: GDFMDriveDocumentView = GDFMDriveDocumentView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
//        m_View.delegate = self
        
        return m_View
    }()
}

//---- MARK: Extensions
extension GDFMDocumentViewController: GDFMDriveDocumentManagerDelegate {
    public func onReceiveFileList(list: [GDFMDriveFile]) {
        didReceivedDriveFileList(list: list)
    }
    
    public func onFileDownloadComplete(tempURL: URL, fileName: String) {
        
    }
    
    public func onFileUploadComplete() {
        
    }
    
    public func onPermisionFailed() {
        handlePermisionFailed()
    }
}

extension GDFMDocumentViewController: GDFMAuthenticationViewControllerDelegate {
    public func onAuthenticationViewControllerDismiss() {
        fetchDriveFileList()
    }
}

