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
        getFileDownloadDetails(file: file, apiKey: apiKey) {
            fileDownloadURL in
            self.downloadActualFile(downloadURL: fileDownloadURL, fileName: file.name, apiKey: apiKey)
        }
    }
    
    //---- Upload file
    public func uploadFileToDrive(fileURL: URL, apiKey: String) {
        var m_URL: URL = URL(string: "https://www.googleapis.com/upload/drive/v3/files")!
        let m_QueryParameterDictionary: [String: String] = [
            "uploadType": "multipart"
        ]
        let m_QueryParameters: [URLQueryItem] = m_QueryParameterDictionary.map{ URLQueryItem(name: $0.key, value: $0.value) }
        m_URL = m_URL.appending(queryItems: m_QueryParameters)
        
        var m_FileData: Data
        do {
            m_FileData = try Data(contentsOf: fileURL)
        } catch {
            fatalError("Upload File Data Error")
        }
        
        var m_Request: URLRequest = URLRequest(url: m_URL)
        m_Request.httpMethod = "POST"
        m_Request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let m_Boundary: String = "Boundary-\(UUID().uuidString)"
        m_Request.setValue("multipart/related; boundary=\(m_Boundary)", forHTTPHeaderField: "Content-Type")
        
        let m_RequestBody: Data = createRequestBodyForUploading(fileName: "new" + fileURL.lastPathComponent, multipartBoundary: m_Boundary, fileData: m_FileData)
        
        let m_RequestTask: URLSessionTask = URLSession.shared.uploadTask(with: m_Request, from: m_RequestBody) {
            data, response, error in
            
            guard let m_Data = data else {
                fatalError("\(error?.localizedDescription ?? "Data nil")")
            }
            
            if (self.delegate != nil) {
                DispatchQueue.main.async {
                    self.delegate!.onFileUploadComplete()
                }
            }
        }
        
        m_RequestTask.resume()
    }
    
    //---- MARK: Helper Methods
    private func getFileDownloadDetails(file: GDFMDriveFile, apiKey: String, completion: @escaping (URL) -> Void) {
        var m_URL: URL = URL(string: "https://www.googleapis.com/drive/v3/files/\(file.id)/download")!
        let m_QueryParameterDictionary: [String: String] = [
            "mimeType": getMimeTypeForFileType(file.mimeType)
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
    
    private func createRequestBodyForUploading(fileName: String, multipartBoundary: String, fileData: Data) -> Data {
        let m_FileName: String = fileName
        let m_Boundary: String = multipartBoundary
        let m_FileData: Data = fileData
        
        let m_MetaData = [
            "name": m_FileName,
            "mimeType": "application/octet-stream"
        ]
    
        var m_MultipartBody: String = ""
        m_MultipartBody += "--\(m_Boundary)\r\n"
        m_MultipartBody += "Content-Type: application/json; charset=UTF-8\r\n\r\n"
        
        if let m_MetaDataJSON: Data = try? JSONSerialization.data(withJSONObject: m_MetaData) {
            m_MultipartBody += String(data: m_MetaDataJSON, encoding: .utf8) ?? ""
        }
        
        m_MultipartBody += "\r\n"
        m_MultipartBody += "--\(m_Boundary)\r\n"
        m_MultipartBody += "Content-Type: application/octet-stream\r\n\r\n"
        
        var m_MultipartBodyData: Data = Data()
        m_MultipartBodyData.append(m_MultipartBody.data(using: .utf8)!)
        m_MultipartBodyData.append(m_FileData)
        m_MultipartBodyData.append("\r\n".data(using: .utf8)!)
        m_MultipartBodyData.append("--\(m_Boundary)--\r\n".data(using: .utf8)!)
        
        return m_MultipartBodyData
    }
    
    private func getMimeTypeForFileType(_ fileType: String) -> String {
        if (fileType.contains("spreadsheet")) {
            return GDFMNameSpace.FileMimeType.googleSheet
        } else if (fileType.contains("document")) {
            return GDFMNameSpace.FileMimeType.googleDoc
        } else if (fileType.contains("presentation")) {
            return GDFMNameSpace.FileMimeType.googlePresentation
        } else {
            return ""
        }
    }
    //---- Check authentication
}

//---- MARK: Delegate Protocol
public protocol GDFMDriveDocumentManagerDelegate {
    func onReceiveFileList(list: [GDFMDriveFile])
    func onFileDownloadComplete(tempURL: URL, fileName: String)
    func onFileUploadComplete()
}
