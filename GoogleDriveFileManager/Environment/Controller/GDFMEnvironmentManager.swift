//
//  GDFMEnvironmentManager.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-07.
//

import Foundation

public class GDFMEnvironmentManager {
    //---- MARK: Properties
    public static var shared: GDFMEnvironmentManager = GDFMEnvironmentManager()
    
    private var g_PropertyList: [String: String] = [:]
    
    //---- MARK: Constructor
    private init() {
        loadEnvironmentProperties()
    }
    
    //---- MARK: Action Methods
    public func getPropertyForKey(_ key: String) -> String? {
        return g_PropertyList[key]
    }
    
    //---- MARK: Helper Methods
    private func loadEnvironmentProperties() {
        if let m_PropertyPListURL: URL = Bundle.main.url(forResource: "env", withExtension: "plist") {
            do {
                let m_Data: Data = try Data(contentsOf: m_PropertyPListURL)
                if let m_Dictionary: [String: String] = try PropertyListSerialization.propertyList(from: m_Data, format: nil) as? [String: String] {
                    g_PropertyList = m_Dictionary
                }
            } catch {
            }
        }
    }
}
