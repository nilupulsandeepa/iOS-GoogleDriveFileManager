//
//  GDFMLocalFileManager.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-08.
//

import Foundation

public class GDFMLocalFileManager {
    
    //---- MARK: Properties
    public static var shared: GDFMLocalFileManager = GDFMLocalFileManager()
    
    private var g_FileManager: FileManager!
    
    public var delegate: GDFMLocalFileManagerDelegate? = nil
    
    //---- MARK: Constructor
    private init() {
        initialize()
    }
    
    //---- MARK: Initialization
    private func initialize() {
        g_FileManager = FileManager.default
    }
    
    //---- MARK: Action Methods
    public func moveFileIntoDocumentsFolder(sourceURL: URL, fileName: String) {
        let m_DocumentsDirectory: URL = g_FileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let m_FinalURL: URL = m_DocumentsDirectory.appendingPathComponent(fileName)
        do {
            if (g_FileManager.fileExists(atPath: m_FinalURL.path())) {
                try g_FileManager.removeItem(at: m_FinalURL)
            }
            try g_FileManager.moveItem(at: sourceURL, to: m_FinalURL)
            print("File Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //---- MARK: Helper Methods
}

//---- MARK: Delegate Protocol
public protocol GDFMLocalFileManagerDelegate {
    
}
