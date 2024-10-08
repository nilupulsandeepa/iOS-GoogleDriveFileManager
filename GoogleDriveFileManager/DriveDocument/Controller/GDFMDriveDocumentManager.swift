//
//  GDFMDriveDocumentManager.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-07.
//

import Foundation

public class GDFMDriveDocumentManager {
    //---- MARK: Properties
    public static var shared: GDFMDriveDocumentManager = GDFMDriveDocumentManager()
    
    private var g_CurrentDriveFileList: [GDFMDriveFile] = []
    
    public var delegate: GDFMDriveDocumentManagerDelegate?
    
    //---- MARK: Constructor
    
    //---- MARK: Initialization
    
    //---- MARK: Action Methods
    public func getListOfFiles() -> [GDFMDriveFile] {
        return g_CurrentDriveFileList
    }
    //---- Get list of files
    public func getListOfFilesFromDrive(apiKey: String) {
        let m_URL: URL = URL(string: "https://www.googleapis.com/drive/v3/files")!
        var m_Request: URLRequest = URLRequest(url: m_URL)
        m_Request.httpMethod = "GET"
        m_Request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let m_RequestTask: URLSessionDataTask = URLSession.shared.dataTask(with: m_Request) {
            data, response, error in
            
            guard let m_Data = data else {
                fatalError("\(error?.localizedDescription ?? "Data nil")")
            }
            
            do {
                print(String(data: m_Data, encoding: .utf8))
                let m_FileList: GDFMDriveFileList = try JSONDecoder().decode(GDFMDriveFileList.self, from: m_Data)
                self.g_CurrentDriveFileList = m_FileList.files
                if (self.delegate != nil) {
                    DispatchQueue.main.async {
                        self.delegate?.onReceiveFileList(list: m_FileList.files)
                    }
                }
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        m_RequestTask.resume()
    }
    //---- Get meta data of a file
    public func getFileMetaData(fileID: String, apiKey: String) {
        let m_URL: URL = URL(string: "https://www.googleapis.com/drive/v3/files/\(fileID)")!
        var m_Request: URLRequest = URLRequest(url: m_URL)
        m_Request.httpMethod = "GET"
        m_Request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let m_RequestTask: URLSessionTask = URLSession.shared.dataTask(with: m_Request) {
            data, response, error in
            //TODO: Implement meta data handling
        }
        m_RequestTask.resume()
    }
    //---- Download file
    public func downloadFileFromDrive(file: GDFMDriveFile, apiKey: String) {
        getFileDownloadDetails(fileID: file.id, apiKey: apiKey) {
            fileDownloadURL in
            self.downloadActualFile(downloadURL: fileDownloadURL, fileName: file.name, apiKey: apiKey)
        }
    }
    
    //---- Download batch of files
    //---- Upload file
    //---- Upload batch of files
    
    //---- MARK: Helper Methods
    private func getFileDownloadDetails(fileID: String, apiKey: String, completion: @escaping (URL) -> Void) {
        var m_URL: URL = URL(string: "https://www.googleapis.com/drive/v3/files/\(fileID)/download")!
        let m_QueryParameterDictionary: [String: String] = [
            "mimeType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        ]
        let m_QueryParameters: [URLQueryItem] = m_QueryParameterDictionary.map{ URLQueryItem(name: $0.key, value: $0.value )}
        m_URL = m_URL.appending(queryItems: m_QueryParameters)
        
        var m_Request: URLRequest = URLRequest(url: m_URL)
        m_Request.httpMethod = "POST"
        m_Request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let m_RequestTask: URLSessionTask = URLSession.shared.dataTask(with: m_Request) {
            data, response, error in
            
            guard let m_Data = data else {
                fatalError("\(error?.localizedDescription ?? "Location nil")")
            }
            
            do {
                let m_FileDownloadDetails: GDFMFileDownloadDetails = try JSONDecoder().decode(GDFMFileDownloadDetails.self, from: data!)
                let m_DownloadURLString: String = m_FileDownloadDetails.response.downloadUri
                let m_DownloadURL: URL = URL(string: m_DownloadURLString)!
                completion(m_DownloadURL)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        m_RequestTask.resume()
    }
    
    private func downloadActualFile(downloadURL: URL, fileName: String, apiKey: String) {
        var m_FileExtension: String = ""
        if let m_QueryComponents: URLComponents = URLComponents(url: downloadURL, resolvingAgainstBaseURL: false) {
            if let m_QueryItems: [URLQueryItem] = m_QueryComponents.queryItems {
                m_FileExtension = m_QueryItems.first {
                    $0.name == "exportFormat"
                }?.value ?? ""
            }
        }
        var m_Request: URLRequest = URLRequest(url: downloadURL)
        m_Request.httpMethod = "GET"
        m_Request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let m_RequestTask: URLSessionTask = URLSession.shared.downloadTask(with: m_Request) {
            location, response, error in
            
            guard let m_Location = location else {
                fatalError("\(error?.localizedDescription ?? "Location nil")")
            }
            
            if (self.delegate != nil) {
                DispatchQueue.main.async {
                    self.delegate!.onFileDownloadComplete(tempURL: m_Location, fileName: "\(fileName).\(m_FileExtension)")
                }
            }
        }
        
        m_RequestTask.resume()
    }
    //---- Check authentication
}

//---- MARK: Delegate Protocol
public protocol GDFMDriveDocumentManagerDelegate {
    func onReceiveFileList(list: [GDFMDriveFile])
    func onFileDownloadComplete(tempURL: URL, fileName: String)
}
