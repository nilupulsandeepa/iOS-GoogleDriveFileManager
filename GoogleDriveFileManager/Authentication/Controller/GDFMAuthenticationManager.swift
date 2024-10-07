//
//  GDFMAuthenticationManager.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-02.
//

import AuthenticationServices

public class GDFMAuthenticationManager: NSObject {
    
    //---- Properties
    public static var shared: GDFMAuthenticationManager = GDFMAuthenticationManager()
    
    private var g_AuthSession: ASWebAuthenticationSession?
    private var g_PresentationAnchor: ASPresentationAnchor?
    
    private var g_GoogleClientID = ""
    private var g_ReversedClientID = ""
    private var g_PermissionScope = "https://www.googleapis.com/auth/drive"
    
    private var g_AuthorizationCode: String? = nil
    
    public var delegate: GDFMAuthenticationDelegate? = nil
    
    //---- Constructor
    private override init() {
        
    }
    
    //---- Initialization
    public func initializeAuthSession() {
        let m_RedirectURI = "\(g_ReversedClientID):/oauthredirect"
        let m_AuthURL = URL(string: "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=\(g_GoogleClientID)&redirect_uri=\(m_RedirectURI)&scope=\(g_PermissionScope)")!
        let m_CallbackScheme = "\(g_ReversedClientID)"
        
        g_AuthSession = ASWebAuthenticationSession(
            url: m_AuthURL,
            callbackURLScheme: m_CallbackScheme) { callBackURL, error in
                if let m_CallBackURL = callBackURL {
                    if let m_AuthCode: String = self.getAuthorizationCode(url: m_CallBackURL) {
                        if (self.delegate != nil) {
                            DispatchQueue.main.async {
                                self.delegate!.didReceiveAuthorizationCode(code: m_AuthCode)
                            }
                        }
                    }
                }
            }
    }
    
    //---- Action Methods
    public func setPresentationAnchor(_ anchor: ASPresentationAnchor) {
        g_PresentationAnchor = anchor
    }
    
    public func requestAPIKey(authCode: String) {
        let m_TokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var m_Request = URLRequest(url: m_TokenURL)
        m_Request.httpMethod = "POST"
        
        let redirectURI = "\(g_ReversedClientID):/oauthredirect"
        
        let bodyParams = [
            "code": authCode,
            "client_id": g_GoogleClientID,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code"
        ]
        let bodyString = bodyParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        m_Request.httpBody = bodyString.data(using: .utf8)
        m_Request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let m_RequestTask: URLSessionDataTask = URLSession.shared.dataTask(with: m_Request) {
            data, response, error in
            
            guard let m_Data = data else {
                fatalError("\(error?.localizedDescription ?? "Data nil")")
            }
            
            do {
                if let m_JSONResponse = try JSONSerialization.jsonObject(with: m_Data) as? [String: Any] {
                    if let m_AccessToken = m_JSONResponse["access_token"] as? String {
                        if (self.delegate != nil) {
                            DispatchQueue.main.async {
                                self.delegate!.didReceiveAPIKey(key: m_AccessToken)
                            }
                        }
                    } else {
                        print("API Key not available")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        m_RequestTask.resume()
    }
    
    //---- Helper Methods
    private func getAuthorizationCode(url: URL) -> String? {
        if let m_Components: URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let m_QueryItems = m_Components.queryItems {
                return m_QueryItems.first { $0.name == "code" }?.value
            }
        }
        return nil
    }
}

extension GDFMAuthenticationManager: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let m_PresentationAnchor = g_PresentationAnchor else { fatalError("GDFMAuthenticationManager: Presentation Anchor found nil while unwrapping") }
        return g_PresentationAnchor!
    }
}


//---- MARK: GDFMAuthentication Delegate Protocol
public protocol GDFMAuthenticationDelegate {
    func didReceiveAuthorizationCode(code: String)
    func didReceiveAPIKey(key: String)
}
