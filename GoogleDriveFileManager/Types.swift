//
//  Types.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-09-26.
//

import Foundation

struct DriveFiles: Codable {
    var files: [File]
}

struct File: Codable {
    var kind: String
    var id: String
    var mimeType: String
    var name: String
}
