//
//  ViewController.swift
//  GoogleDriveFileManager
//
//  Created by Nilupul Sandeepa on 2024-09-25.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.signInWithGoogle()
//            self.getGoogleDriveFiles(accessToken: self.accessToken)
        })
    }

    var authSession: ASWebAuthenticationSession?
    var accessToken: String = ""

        func signInWithGoogle() {
            let clientID = ""
            let redirectURI = ":/oauthredirect"
            let scope = "https://www.googleapis.com/auth/drive"
            let authURL = URL(string: "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scope)")!
            let callbackScheme = ""

            // Start ASWebAuthenticationSession
            authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { callbackURL, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let callbackURL = callbackURL, let code = self.extractAuthorizationCode(from: callbackURL) {
                    // Use the authorization code to get tokens
                    self.exchangeAuthorizationCodeForToken(code: code)
                }
            }
            authSession?.presentationContextProvider = self
            authSession?.start()
        }

        func extractAuthorizationCode(from url: URL) -> String? {
            print("URL -> \(url.absoluteString)")
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            return components?.queryItems?.first(where: { item in
                item.name == "code"
            })?.value
//            return components?.queryItems?.first(where: { $0.name == "code" })?.value
        }

        func exchangeAuthorizationCodeForToken(code: String) {
            // Prepare request to exchange code for access token
            let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
            var request = URLRequest(url: tokenURL)
            request.httpMethod = "POST"
            let clientID = ""
            let redirectURI = ":/oauthredirect"
            
            let bodyParams = [
                "code": code,
                "client_id": clientID,
                "redirect_uri": redirectURI,
                "grant_type": "authorization_code"
            ]
            
            let bodyString = bodyParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let accessToken = jsonResponse["access_token"] as? String {
                            print("Access Token: \(accessToken)")
                            // Use this access token for Google Drive API requests
                            self.getGoogleDriveFiles(accessToken: accessToken)
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
        
        func getGoogleDriveFiles(accessToken: String) {
            let url = URL(string: "https://www.googleapis.com/drive/v3/files")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let respose = try JSONDecoder().decode(DriveFiles.self, from: data)
                    print(respose)
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Files: ")
                        print("\(jsonResponse)")
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
}
