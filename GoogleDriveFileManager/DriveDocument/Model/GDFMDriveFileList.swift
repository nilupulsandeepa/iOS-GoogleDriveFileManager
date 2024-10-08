//
//  GDFMDriveFileList.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-07.
//

import Foundation

public struct GDFMDriveFileList: Codable {
    var files: [GDFMDriveFile]
}

public struct GDFMDriveFile: Codable {
    var kind: String
    var id: String
    var mimeType: String
    var name: String
}

