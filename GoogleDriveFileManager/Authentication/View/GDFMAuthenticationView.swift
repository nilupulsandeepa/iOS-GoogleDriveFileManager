//
//  GDFMAuthenticationView.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-09.
//

import UIKit

public class GDFMAuthenticationView: UIView {
    //---- MARK: Properties
    public var delegate: GDFMAuthenticationViewDelegate?
    
    //---- MARK: Constructor
    init() {
        super.init(frame: .zero)
        
        addSubview(g_GoogleSignInView)
        g_GoogleSignInView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        g_GoogleSignInView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        g_GoogleSignInView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        g_GoogleSignInView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(g_LoadingView)
        g_LoadingView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        g_LoadingView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        g_LoadingView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        g_LoadingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //---- MARK: Intialization
    
    //---- MARK: Action Methods
    public func showGoogleSignInView() {
        g_LoadingView.isHidden = true
        g_GoogleSignInView.isHidden = false
    }
    
    public func showLoadingView() {
        g_LoadingView.isHidden = false
        g_GoogleSignInView.isHidden = true
    }
    
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
    @objc private func onGoogleSignInButtonTap() {
        if (delegate != nil) {
            delegate!.onGoogleSignInButtonTap()
        }
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
    
    private lazy var g_GoogleSignInView: UIView = {
        let m_View: UIView = UIView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.backgroundColor = .white
        
        m_View.addSubview(g_GoogleDriveIcon)
        g_GoogleDriveIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        g_GoogleDriveIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        g_GoogleDriveIcon.centerXAnchor.constraint(equalTo: m_View.centerXAnchor).isActive = true
        g_GoogleDriveIcon.centerYAnchor.constraint(equalTo: m_View.centerYAnchor).isActive = true
        
        m_View.addSubview(g_GoogleSignInButton)
        g_GoogleSignInButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        g_GoogleSignInButton.centerXAnchor.constraint(equalTo: m_View.centerXAnchor).isActive = true
        g_GoogleSignInButton.topAnchor.constraint(equalTo: g_GoogleDriveIcon.bottomAnchor, constant: 64).isActive = true
        
        return m_View
    }()
    
    private lazy var g_GoogleDriveIcon: UIImageView = {
        let m_View: UIImageView = UIImageView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.image = UIImage(named: "img_drive_icon")
        m_View.contentMode = .scaleAspectFill
        m_View.backgroundColor = .clear
        
        return m_View
    }()
    
    private lazy var g_GoogleSignInButton: UIView = {
        let m_View: UIView = UIView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.layer.borderWidth = 1
        m_View.layer.borderColor = UIColor.black.cgColor
        m_View.layer.cornerRadius = 22
        
        m_View.isUserInteractionEnabled = true
        m_View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onGoogleSignInButtonTap)))
        
        m_View.addSubview(g_GoogleSignInButtonIcon)
        g_GoogleSignInButtonIcon.leadingAnchor.constraint(equalTo: m_View.leadingAnchor, constant: 8).isActive = true
        g_GoogleSignInButtonIcon.widthAnchor.constraint(equalTo: m_View.heightAnchor, constant: -16).isActive = true
        g_GoogleSignInButtonIcon.topAnchor.constraint(equalTo: m_View.topAnchor, constant: 8).isActive = true
        g_GoogleSignInButtonIcon.heightAnchor.constraint(equalTo: m_View.heightAnchor, constant: -16).isActive = true
        
        m_View.addSubview(g_GoogleSignInButtonLabel)
        g_GoogleSignInButtonLabel.leadingAnchor.constraint(equalTo: g_GoogleSignInButtonIcon.trailingAnchor, constant: 8).isActive = true
        g_GoogleSignInButtonLabel.trailingAnchor.constraint(equalTo: m_View.trailingAnchor, constant: -8).isActive = true
        g_GoogleSignInButtonLabel.centerYAnchor.constraint(equalTo: m_View.centerYAnchor).isActive = true
        
        return m_View
    }()
    
    private lazy var g_GoogleSignInButtonIcon: UIImageView = {
        let m_View: UIImageView = UIImageView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.image = UIImage(named: "img_google_icon")
        m_View.contentMode = .scaleAspectFill
        m_View.backgroundColor = .clear
        
        return m_View
    }()
    
    private lazy var g_GoogleSignInButtonLabel: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Sign in with Google"
        
        return m_View
    }()
}

//---- MARK: Authentication View Protocol
public protocol GDFMAuthenticationViewDelegate {
    func onGoogleSignInButtonTap()
}
