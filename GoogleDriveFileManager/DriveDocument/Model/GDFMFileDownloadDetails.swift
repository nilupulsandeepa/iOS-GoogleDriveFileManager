//
//  GDFMFileDownloadDetails.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-08.
//

import Foundation

public struct GDFMFileDownloadDetails: Codable {
    var response: GDFMFileDownloadDetailsResponse
}

public struct GDFMFileDownloadDetailsResponse: Codable {
    var downloadUri: String
}
