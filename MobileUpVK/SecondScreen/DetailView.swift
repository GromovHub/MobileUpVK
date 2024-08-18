//
//  Project name: MobileUpVK
//  File name: DetailView.swift
//
//  Copyright © Gromov V.O., 2024
//

import UIKit
import WebKit


enum ContentType {
    case photo(VKPhotoItem,UIImage)
    case webView(VKVideoItem)
}

class DetailView: UIViewController {

    private let contentType: ContentType
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var webView: WKWebView = {
        let wv = WKWebView()
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()
    
    
    init(contentType: ContentType) {
        self.contentType = contentType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .systemBackground
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareAction))
        navigationItem.rightBarButtonItem = shareButton
        navigationController?.navigationBar.tintColor = .whiteDarkBlackLight
        
        
        switch contentType {
        case .photo:
            view.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        case .webView:
            view.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
    
    
    private func loadContent() {
        switch contentType {
        case .photo(let vKPhotoItem, let uIImage):
            imageView.image = uIImage
            navigationItem.title = vKPhotoItem.date.toDateString()
        case .webView(let vKVideoItem):
            navigationItem.title = vKVideoItem.title
            webView.load(URLRequest(url: URL(string: vKVideoItem.player)!))
            
        }
    }
    
    // save/share photo works
    // share url works
    @objc func shareAction() {
        var items: [Any] = []
        var activityViewController: UIActivityViewController? = nil
        switch contentType {
        case .photo(_, let uIImage):
            items = [uIImage]
            activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        case .webView(let vKVideoItem):
            items = [vKVideoItem.player]
            activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        }
        present(activityViewController!, animated: true, completion: nil)
    }
}
