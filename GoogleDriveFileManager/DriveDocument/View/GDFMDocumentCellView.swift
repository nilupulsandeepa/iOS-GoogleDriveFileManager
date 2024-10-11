//
//  GDFMDocumentCellView.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-10.
//

import UIKit

public class GDFMDocumentCellView: UICollectionViewCell {
    //---- MARK: Properties
    private var g_ItemIndex: Int? = nil
    
    public var delegate: GDFMDocumentCellViewDelegate?
    
    //---- MARK: Constructor
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    //---- MARK: Initialization
    private func configureUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(g_DocumentIcon)
        g_DocumentIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        g_DocumentIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        g_DocumentIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        g_DocumentIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        contentView.addSubview(g_DocumentName)
        g_DocumentName.leadingAnchor.constraint(equalTo: g_DocumentIcon.trailingAnchor, constant: 8).isActive = true
        g_DocumentName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        g_DocumentName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        
        contentView.addSubview(g_DocumentType)
        g_DocumentType.leadingAnchor.constraint(equalTo: g_DocumentName.leadingAnchor).isActive = true
        g_DocumentType.topAnchor.constraint(equalTo: g_DocumentName.bottomAnchor, constant: 8).isActive = true
        g_DocumentType.trailingAnchor.constraint(equalTo: g_DocumentName.trailingAnchor).isActive = true
        
        contentView.addSubview(g_OptionIcon)
        g_OptionIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        g_OptionIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        g_OptionIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        g_OptionIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    //---- MARK: Action Methods
    public func setFile(file: GDFMDriveFile) {
        g_DocumentName.text = file.name
        g_DocumentType.text = getFileType(type: file.mimeType)
        g_DocumentIcon.image = getFileTypeIcon(type: file.mimeType)
    }
    
    public func setItemIdex(index: Int) {
        g_ItemIndex = index
    }
    
    
    //---- MARK: Helper Methods
    private func getFileType(type: String) -> String {
        if (type.contains("spreadsheet")) {
            return GDFMNameSpace.FileType.googleSheet
        } else if (type.contains("document")) {
            return GDFMNameSpace.FileType.googleDoc
        } else if (type.contains("presentation")) {
            return GDFMNameSpace.FileType.googlePresentation
        } else {
            return GDFMNameSpace.FileType.other
        }
    }
    
    private func getFileTypeIcon(type: String) -> UIImage {
        if (type.contains("spreadsheet")) {
            return UIImage(named: "img_google_sheet_icon")!
        } else if (type.contains("document")) {
            return UIImage(named: "img_google_doc_icon")!
        } else if (type.contains("presentation")) {
            return UIImage(named: "img_google_presentation_icon")!
        } else {
            return UIImage(named: "img_other_icon")!
        }
    }
    
    @objc private func onOptionIconTap() {
        if (delegate != nil) {
            DispatchQueue.main.async {
                self.delegate!.onOptionSelect(fileIndex: self.g_ItemIndex!)
            }
        }
    }
    
    //---- MARK: UI Components
    private lazy var g_DocumentIcon: UIImageView = {
        let m_View: UIImageView = UIImageView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.image = UIImage(named: "img_google_sheet_icon")
        m_View.contentMode = .scaleAspectFill
        
        return m_View
    }()
    
    private lazy var g_DocumentName: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "MyBudget"
        m_View.textAlignment = .left
        m_View.textColor = .black
        m_View.font = .systemFont(ofSize: 18)
        
        return m_View
    }()
    
    private lazy var g_DocumentType: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Google Sheet"
        m_View.textAlignment = .left
        m_View.textColor = .black
        m_View.font = .systemFont(ofSize: 12)
        
        return m_View
    }()
    
    private lazy var g_OptionIcon: UIImageView = {
        let m_View: UIImageView = UIImageView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.image = UIImage(systemName: "ellipsis.circle")!.withRenderingMode(.alwaysTemplate)
        m_View.tintColor = .gray
        m_View.contentMode = .scaleAspectFill
        
        m_View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOptionIconTap)))
        m_View.isUserInteractionEnabled = true
        
        return m_View
    }()
}


//---- MARK: Document Cell View Protocol
public protocol GDFMDocumentCellViewDelegate {
    func onOptionSelect(fileIndex: Int)
}
