//
//  GDFMAuthenticationManager.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-10-02.
//

import AuthenticationServices

public class GDFMAuthenticationManager: NSObject {
    
    //---- MARK: Properties
    public static var shared: GDFMAuthenticationManager = GDFMAuthenticationManager()
    
    private var g_AuthSession: ASWebAuthenticationSession?
    private var g_PresentationAnchor: ASPresentationAnchor?
    private var g_GoogleClientID = ""
    private var g_ReversedClientID = ""
    private var g_PermissionScope = "https://www.googleapis.com/auth/drive"
    
    private var g_AuthorizationCode: String? = nil
    
    public var delegate: GDFMAuthenticationDelegate? = nil
    
    //---- MARK: Constructor
    private override init() {
        
    }
    
    //---- MARK: Initialization
    public func initializeAuthSession() {
        g_GoogleClientID = GDFMEnvironmentManager.shared.getPropertyForKey("GoogleClientID") ?? ""
        g_ReversedClientID = GDFMEnvironmentManager.shared.getPropertyForKey("ReversedClientID") ?? ""
        
        let m_RedirectURI = "\(g_ReversedClientID):/oauthredirect"
        var m_AuthURL = URL(string: "https://accounts.google.com/o/oauth2/auth")!
        let m_QueryParameterDictionary: [String: String] = [
            "response_type": "code",
            "client_id": g_GoogleClientID,
            "redirect_uri": m_RedirectURI,
            "scope": g_PermissionScope
        ]
        let m_QueryParameters: [URLQueryItem] = m_QueryParameterDictionary.map{ URLQueryItem(name: $0.key, value: $0.value) }
        m_AuthURL = m_AuthURL.appending(queryItems: m_QueryParameters)
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
                    } else {
                        if (self.delegate != nil) {
                            DispatchQueue.main.async {
                                self.delegate!.onAuthorizationFail()
                            }
                        }
                    }
                } else {
                    if (self.delegate != nil) {
                        DispatchQueue.main.async {
                            self.delegate!.onAuthorizationFail()
                        }
                    }
                }
            }
        
        g_AuthSession!.presentationContextProvider = self
        g_AuthSession!.start()
    }
    
    //---- MARK: Action Methods
    public func setPresentationAnchor(_ anchor: ASPresentationAnchor) {
        g_PresentationAnchor = anchor
    }
    
    public func requestAPIKey(authCode: String) {
        let m_TokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        
        var m_Request = URLRequest(url: m_TokenURL)
        m_Request.httpMethod = "POST"
        m_Request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let m_RedirectURI = "\(g_ReversedClientID):/oauthredirect"
        let m_BodyParams = [
            "code": authCode,
            "client_id": g_GoogleClientID,
            "redirect_uri": m_RedirectURI,
            "grant_type": "authorization_code"
        ]
        let bodyString = m_BodyParams.map{ "\($0.key)=\($0.value)" }.joined(separator: "&")
        m_Request.httpBody = bodyString.data(using: .utf8)

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
    
    //---- MARK: Helper Methods
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
        guard g_PresentationAnchor != nil else { fatalError("GDFMAuthenticationManager: Presentation Anchor found nil while unwrapping") }
        return g_PresentationAnchor!
    }
}


//----MARK: GDFMAuthentication Delegate Protocol
public protocol GDFMAuthenticationDelegate {
    func didReceiveAuthorizationCode(code: String)
    func didReceiveAPIKey(key: String)
    func onAuthorizationFail()
}
