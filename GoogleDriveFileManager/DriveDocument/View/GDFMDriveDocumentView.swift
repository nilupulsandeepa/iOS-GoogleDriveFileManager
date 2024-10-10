//
//  GDFMDriveDocumentView.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-10.
//

import UIKit

public class GDFMDriveDocumentView: UIView {
    //---- MARK: Properties
    
    //---- MARK: Constructor
    init() {
        super.init(frame: .zero)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //---- MARK: Initialization
    
    //---- MARK: Action Methods
    public func startActivityIndicatorAnimation() {
        g_ActivityIndicator.startAnimating()
    }
    
    public func stopActivityIndicatorAnimation() {
        g_ActivityIndicator.stopAnimating()
    }
    
    public func changeActivityStatusLabelText(text: String) {
        g_ActivityStatusLabel.text = text
    }
    
    //---- MARK: Helper Methods
    private func configureUI() {
        addSubview(g_LoadingView)
        g_LoadingView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        g_LoadingView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        g_LoadingView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        g_LoadingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    //---- MARK: UI Components
    private lazy var g_LoadingView: UIView = {
        let m_View: UIView = UIView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.backgroundColor = .white
        
        m_View.addSubview(g_ActivityIndicator)
        g_ActivityIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        g_ActivityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        g_ActivityIndicator.centerXAnchor.constraint(equalTo: m_View.centerXAnchor).isActive = true
        g_ActivityIndicator.centerYAnchor.constraint(equalTo: m_View.centerYAnchor).isActive = true
        
        m_View.addSubview(g_ActivityStatusLabel)
        g_ActivityStatusLabel.widthAnchor.constraint(equalTo: m_View.widthAnchor, multiplier: 1.0, constant: -32).isActive = true
        g_ActivityStatusLabel.topAnchor.constraint(equalTo: g_ActivityIndicator.bottomAnchor, constant: 8).isActive = true
        g_ActivityStatusLabel.centerXAnchor.constraint(equalTo: m_View.centerXAnchor).isActive = true
        
        return m_View
    }()
    
    private lazy var g_ActivityIndicator: UIActivityIndicatorView = {
        let m_View: UIActivityIndicatorView = UIActivityIndicatorView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.style = .medium
        m_View.color = UIColor(red: 227.0 / 255.0, green: 117.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)
        
        return m_View
    }()
    
    private lazy var g_ActivityStatusLabel: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Checking Permision..."
        m_View.textAlignment = .center
        
        return m_View
    }()
    
    private lazy var g_DocumentCollectionView: UICollectionView = {
        let m_View: UICollectionView = UICollectionView()
        
        
        return m_View
    }()
}
