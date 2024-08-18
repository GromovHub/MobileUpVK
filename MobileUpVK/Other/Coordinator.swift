//
//  Project name: MobileUpVK
//  File name: Coordinator.swift
//
//  Copyright © Gromov V.O., 2024
//

import UIKit

class Coordinator {
    
    let navigationController: UINavigationController
    
    // MARK: - Screens
    
    lazy var welcomeViewController: WelcomeViewController = {
        let vc = WelcomeViewController()
        vc.coordinator = self
        return vc
    }()
    
    lazy var webKitViewController: WebKitViewController = {
        let vc = WebKitViewController()
        vc.coordinator = self
        return vc
    }()
    
    lazy var mediaViewController: MediaViewController = {
        let vc = MediaViewController()
        vc.coordinator = self
        return vc
    }()
    
    // MARK: - Functions
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        TokenManager.isTokenValid() ? showMediaViewController() : showWelcomeScreen()
    }
    
    func showWelcomeScreen() {
        self.navigationController.viewControllers.removeAll()
        self.navigationController.pushViewController(welcomeViewController, animated: true)
    }
    
    func showAuthWebViewModal() {
        // UINavigationController for close bar button
        navigationController.present(UINavigationController(rootViewController: webKitViewController), animated: true, completion: nil)
    }
    
    func showMediaViewController() {
        navigationController.pushViewController(mediaViewController, animated: true)
        
    }
    
    func showDetailView(with: ContentType) {
        navigationController.pushViewController(DetailView(contentType: with), animated: true)
    }
}
