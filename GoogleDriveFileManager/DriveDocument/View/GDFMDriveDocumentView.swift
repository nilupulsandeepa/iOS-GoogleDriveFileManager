//
//  GDFMDriveDocumentView.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-10.
//

import UIKit

public class GDFMDriveDocumentView: UIView {
    //---- MARK: Properties
    public var delegate: GDFMDriveDocumentViewDelegate?
    
    private var g_FileList: [GDFMDriveFile] = []
    
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
    
    public func hideLoadingView() {
        g_LoadingView.isHidden = true
    }
    
    public func showLoadingView() {
        g_LoadingView.isHidden = false
    }
    
    public func updateFileList(list: [GDFMDriveFile]) {
        g_FileList = list
        g_DocumentCollectionView.reloadData()
    }
    
    //---- MARK: Helper Methods
    private func configureUI() {
        self.backgroundColor = .white
        
        addSubview(g_UploadButtonView)
        g_UploadButtonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        g_UploadButtonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        g_UploadButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        g_UploadButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        addSubview(g_DocumentCollectionView)
        g_DocumentCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        g_DocumentCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        g_DocumentCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        g_DocumentCollectionView.bottomAnchor.constraint(equalTo: g_UploadButtonView.topAnchor, constant: -8).isActive = true
        
        addSubview(g_LoadingView)
        g_LoadingView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        g_LoadingView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        g_LoadingView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        g_LoadingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func didSelectOptionsForCellAt(index: Int) {
        if (delegate != nil) {
            DispatchQueue.main.async {
                self.delegate!.onOptionButtonTap(fileIndex: index)
            }
        }
    }
    
    @objc private func onUploadButtonTap() {
        if (delegate != nil) {
            DispatchQueue.main.async {
                self.delegate!.onUploadButtonTap()
            }
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
        m_View.textColor = .black
        
        return m_View
    }()
    
    private lazy var g_DocumentCollectionView: UICollectionView = {
        let m_Layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let m_View: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: m_Layout)
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.dataSource = self
        m_View.delegate = self
        m_View.register(GDFMDocumentCellView.self, forCellWithReuseIdentifier: GDFMNameSpace.CollectionViewCellIdentifiers.driveDocumentCellIdentifier)
        m_View.backgroundColor = UIColor(red: 237 / 255, green: 237 / 255, blue: 237 / 255, alpha: 1.0)
        m_View.isScrollEnabled = true
        m_View.showsHorizontalScrollIndicator = false
        m_View.showsVerticalScrollIndicator = false
        m_View.allowsMultipleSelection = false
        
        return m_View
    }()
    
    private lazy var g_UploadButtonView: UIView = {
        let m_View: UIView = UIView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.layer.cornerRadius = 25
        m_View.backgroundColor = UIColor(red: 95 / 255, green: 125 / 255, blue: 245 / 255, alpha: 1.0)
        
        m_View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onUploadButtonTap)))
        
        m_View.addSubview(g_UploadButtonText)
        g_UploadButtonText.widthAnchor.constraint(equalTo: m_View.widthAnchor, constant: -16).isActive = true
        g_UploadButtonText.centerXAnchor.constraint(equalTo: m_View.centerXAnchor).isActive = true
        g_UploadButtonText.centerYAnchor.constraint(equalTo: m_View.centerYAnchor).isActive = true
        
        return m_View
    }()
    
    private lazy var g_UploadButtonText: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Upload"
        m_View.textAlignment = .center
        m_View.textColor = .white
        
        return m_View
    }()
}

extension GDFMDriveDocumentView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return g_FileList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let m_ViewCell: GDFMDocumentCellView = collectionView.dequeueReusableCell(withReuseIdentifier: GDFMNameSpace.CollectionViewCellIdentifiers.driveDocumentCellIdentifier, for: indexPath) as! GDFMDocumentCellView
        m_ViewCell.setFile(file: g_FileList[indexPath.row])
        m_ViewCell.delegate = self
        m_ViewCell.setItemIdex(index: indexPath.row)
        return m_ViewCell
    }
}

extension GDFMDriveDocumentView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width - 24, height: 66)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
}

extension GDFMDriveDocumentView: GDFMDocumentCellViewDelegate {
    public func onOptionSelect(fileIndex: Int) {
        didSelectOptionsForCellAt(index: fileIndex)
    }
}

//---- MARK: Drive Document View Protocol
public protocol GDFMDriveDocumentViewDelegate {
    func onUploadButtonTap()
    func onOptionButtonTap(fileIndex: Int)
}
