//
//  Project name: MobileUpVK
//  File name: WebKitViewController.swift
//
//  Copyright © Gromov V.O., 2024
//

import UIKit
import WebKit

class WebKitViewController: UIViewController {
    
    var coordinator: Coordinator?
    let webView = WKWebView()
    
    override func viewDidLoad() {
        setupViews()
    }
    
    // if relogin
    override func viewIsAppearing(_ animated: Bool) {
        loadWebView()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemGray6
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        navigationItem.title = Strings.webViewTitle
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeWebView))
        navigationItem.leftBarButtonItem = closeButton
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
    }
    
    @objc func closeWebView() {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadWebView() {
        switch vKAuthURLConstructor() {
        case .success(let url):
            webView.load(URLRequest(url: url))
        case .failure(let error):
            closeWebView()
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
}

// MARK: - extension WebKit delegate

// handle url changes in WebView
extension WebKitViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        let currentUrl = navigationAction.request.url!.absoluteString
        if currentUrl.contains("access_token") {
            decisionHandler(.cancel)
        
            switch extractVKAccessTokenAndExpiration(from: currentUrl) {
            case .success((let token, let expireTime)):
                dismiss(animated: true)
                TokenManager.saveToken(token: token, expiresIn: expireTime)
                coordinator?.showMediaViewController()
            case .failure(let error):
                self.showAlert(title: error.localizedDescription, message: "can't get access\ntry again")
            }

        } else {
            decisionHandler(.allow)
        }
    }
}

// MARK: - VK auth constructor

extension WebKitViewController {
    func vKAuthURLConstructor() -> Result<URL, Error>  {
        var baseUrl = URLComponents(string: "https://oauth.vk.com/authorize")!
        baseUrl.queryItems = [
            URLQueryItem(name: "client_id", value: "52164662"), // VK App ID
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope", value: "friends,photos,groups,video"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.199")
        ]
        
        if let url = baseUrl.url {
            return .success(url)
        } else {
            return .failure(MobileUpProjectError.invalidURL("func vKAuthURLConstructor()"))
        }
    }
}


// MARK: - VK token extractor
extension WebKitViewController {
    
    func extractVKAccessTokenAndExpiration(from urlString: String) -> Result<(String, Int), Error> {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let authorizeUrl = queryItems.first(where: { $0.name == "authorize_url" })?.value,
              let decodedAuthorizeUrl = authorizeUrl.removingPercentEncoding,
              let authorizeComponents = URLComponents(string: decodedAuthorizeUrl),
              let fragment = authorizeComponents.fragment else {
            WKWebView.clearAllWebsiteData()
            return .failure(MobileUpProjectError.tokenError("func extractVKAccessTokenAndExpiration"))
        }
        
        let fragmentComponents = fragment.components(separatedBy: "&")
        
        guard let accessToken = fragmentComponents
            .first(where: { $0.starts(with: "access_token=") })?
            .components(separatedBy: "=")
            .last,
              let expiresInString = fragmentComponents
            .first(where: { $0.starts(with: "expires_in=") })?
            .components(separatedBy: "=")
            .last,
              let expiresIn = Int(expiresInString) else {
            WKWebView.clearAllWebsiteData()
            return .failure(MobileUpProjectError.tokenError("func extractVKAccessTokenAndExpiration"))
        }
        
        print("""
---current token---
\(accessToken)
-------------------
""")
        print("""
---expires in---
\(expiresIn) seconds
----------------
""")
        return .success((accessToken, expiresIn))
    }
}

// MARK: - WebView cache cleaner

extension WKWebView {
    static func clearAllWebsiteData() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                 for: records,
                                 completionHandler: {})
        }
        print("WebView Cleaned")
    }
}
