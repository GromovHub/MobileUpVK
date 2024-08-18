//
//  Project name: MobileUpVK
//  File name: WelcomeViewController.swift
//
//  Copyright © Gromov V.O., 2024
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var coordinator: Coordinator?
    
    // MARK: -  ui elements

    var activityIndicator: UIActivityIndicatorView!
    
    let welcomeLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = Strings.welcomeSign
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 44, weight: .bold)
        return lbl
    }()
    
    let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(Strings.loginButton, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        setupViews()
        updateButtonAppearance()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(welcomeLabel)
        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true
        welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        
        view.addSubview(loginButton)
        loginButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        
        setupActivityIndicator()
    }
    
    @objc func loginTapped() {
        showLoading()
        coordinator?.showAuthWebViewModal()
    }
    
    // Change color according device theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateButtonAppearance()
        }
    }
    
    func updateButtonAppearance() {
        if traitCollection.userInterfaceStyle == .dark {
            loginButton.backgroundColor = .white
            loginButton.setTitleColor(.black, for: .normal)
        } else {
            loginButton.backgroundColor = .black
            loginButton.setTitleColor(.white, for: .normal)
        }
    }
}

//import SwiftUI
//@available(iOS 17, *)
//#Preview(body: {
//    UINavigationController(rootViewController: WelcomeViewController())
//})

// MARK: - activity indicator

extension WelcomeViewController {
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideLoading()
        }
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
}
