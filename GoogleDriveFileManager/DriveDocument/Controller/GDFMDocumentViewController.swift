//
//  GDFMDocumentViewController.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-07.
//

import UIKit

public class GDFMDocumentViewController: UIViewController {
    public override func viewDidLoad() {
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
        g_DocumentView.updateFileList(list: list)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.g_DocumentView.hideLoadingView()
        })
    }
    
    private func handlePermisionFailed() {
        g_DocumentView.changeActivityStatusLabelText(text: "Permision Failed...")
        GDFMUserDefaultManager.shared.googleAPIKey = "_none"
        //Intentional Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.showAuthenticationViewController()
        })
    }
    
    private func didTapUploadButton() {
        let m_DocumentPickerViewController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
        m_DocumentPickerViewController.modalPresentationStyle = .formSheet
        m_DocumentPickerViewController.delegate = self
        present(m_DocumentPickerViewController, animated: true)
    }
    
    private func filePickedForUploading(url: URL) {
        g_DocumentView.showLoadingView()
        g_DocumentView.startActivityIndicatorAnimation()
        g_DocumentView.changeActivityStatusLabelText(text: "Uploading...")
        GDFMDriveDocumentManager.shared.uploadFileToDrive(fileURL: url, apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
    }
    
    private func didCompletedUploading() {
        g_DocumentView.stopActivityIndicatorAnimation()
        g_DocumentView.changeActivityStatusLabelText(text: "File Uploaded")
        //---- Intentional Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.fetchDriveFileList()
        })
    }
    
    private func downloadFileFromDrive(fileIndex: Int) {
        g_DocumentView.showLoadingView()
        g_DocumentView.startActivityIndicatorAnimation()
        g_DocumentView.changeActivityStatusLabelText(text: "File Downloading...")
        GDFMDriveDocumentManager.shared.downloadFileFromDrive(file: GDFMDriveDocumentManager.shared.getListOfFiles()[fileIndex], apiKey: GDFMUserDefaultManager.shared.googleAPIKey)
    }
    
    private func didCompleteDownloading(tempURL: URL, fileName: String) {
        GDFMLocalFileManager.shared.moveFileIntoDocumentsFolder(sourceURL: tempURL, fileName: fileName)
        g_DocumentView.stopActivityIndicatorAnimation()
        g_DocumentView.changeActivityStatusLabelText(text: "File Downloaded")
        //---- Intentional Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.g_DocumentView.hideLoadingView()
        })
    }
    
    private func didTapOptionIconFor(fileIndex: Int) {
        let m_AlertView: UIAlertController = UIAlertController(title: "Options", message: "Choose an action", preferredStyle: .actionSheet)
        m_AlertView.addAction(UIAlertAction(title: "Download File", style: .default, handler: {
            alert in
            self.downloadFileFromDrive(fileIndex: fileIndex)
        }))
        m_AlertView.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(m_AlertView, animated: true)
    }
    
    //---- MARK: UI Components
    private lazy var g_DocumentView: GDFMDriveDocumentView = {
        let m_View: GDFMDriveDocumentView = GDFMDriveDocumentView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.delegate = self
        
        return m_View
    }()
}

//---- MARK: Extensions
extension GDFMDocumentViewController: GDFMDriveDocumentManagerDelegate {
    public func onReceiveFileList(list: [GDFMDriveFile]) {
        didReceivedDriveFileList(list: list)
    }
    
    public func onFileDownloadComplete(tempURL: URL, fileName: String) {
        didCompleteDownloading(tempURL: tempURL, fileName: fileName)
    }
    
    public func onFileUploadComplete() {
        didCompletedUploading()
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

extension GDFMDocumentViewController: GDFMDriveDocumentViewDelegate {
    public func onUploadButtonTap() {
        didTapUploadButton()
    }
    
    public func onOptionButtonTap(fileIndex: Int) {
        didTapOptionIconFor(fileIndex: fileIndex)
    }
}

extension GDFMDocumentViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        filePickedForUploading(url: urls[0])
    }
}
