//
//  AutorizationViewController.swift
//  Course2FinalTask
//
//  Created by Евгений on 19.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

final class AutorizationViewController: UIViewController {
    
    //    MARK: - Private Properties
    private var appDelegate = AppDelegate.shared
    private var apiManager = APIListManager()
    private lazy var alert = AlertViewController(view: self)
    private let keychain: KeychainProtocol = KeychainManager()
    private lazy var block = BlockViewController(view: view)
    
    // MARK: - Public Properties
    var dataManager: CoreDataInstagram!
    
    private lazy var loginText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Login", tableName: "Localizable", bundle: .main, value: "", comment: "")
        textField.textContentType = .username
        textField.keyboardType = .emailAddress
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputText), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Password", tableName: "Localizable", bundle: .main, value: "", comment: "")
        textField.textContentType = .password
        textField.keyboardType = .asciiCapable
        textField.borderStyle = .roundedRect
        if #available(iOS 13.0, *) {
            textField.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        textField.font = .systemFont(ofSize: 14)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputText), for: .editingChanged)
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.setTitle( NSLocalizedString("Sign in", tableName: "Localizable", bundle: .main, value: "", comment: ""), for: .normal)
        button.alpha = 0.3
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(signinPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = keychain.readToken(userName: "user") else { return }
        block.startAnimating()
        APIListManager.token = token
        block.stopAnimating()
        presentTabBarController()
    }
    
    
    //    MARK: - Private Methods
    private func createUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        let elements = [loginText, passwordText, loginButton]
        
        elements.forEach { (element) in
            view.addSubview(element)
        }
        
        let constraints = [loginText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                           loginText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                           loginText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                           loginText.heightAnchor.constraint(equalToConstant: 40),
                           
                           passwordText.topAnchor.constraint(equalTo: loginText.bottomAnchor, constant: 8),
                           passwordText.leadingAnchor.constraint(equalTo: loginText.leadingAnchor),
                           loginText.trailingAnchor.constraint(equalTo: loginText.trailingAnchor),
                           passwordText.heightAnchor.constraint(equalToConstant: 40),
                           
                           loginButton.topAnchor.constraint(equalTo: passwordText.bottomAnchor, constant: 100),
                           loginButton.leadingAnchor.constraint(equalTo: loginText.leadingAnchor),
                           loginButton.trailingAnchor.constraint(equalTo: loginText.trailingAnchor),
                           loginButton.heightAnchor.constraint(equalToConstant: 50)]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func presentTabBarController() {
        
        let storyboard = UIStoryboard(name: AppDelegate.storyboardName, bundle: nil)
        guard let tabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as? TabBarController else { return }
        appDelegate.window?.rootViewController = tabBar
    }
    
    @objc private func inputText() {
        guard let login = loginText.text,
              let password = passwordText.text else { return }
        loginButton.isEnabled = !login.isEmpty && !password.isEmpty
        loginButton.alpha = loginButton.isEnabled ? 1 : 0.3
    }
    
    @objc private func signinPressed() {
        guard let login = loginText.text,
              let password = passwordText.text else { return }
        apiManager.signin(login: login, password: password) { [weak self] (result) in
            
            switch result {
            case .success(let token):
                
                APIListManager.token = token.token
                
                let storyboard = UIStoryboard(name: AppDelegate.storyboardName, bundle: nil)
                
                guard let tabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as? TabBarController else { return }
                
                self?.appDelegate.window?.rootViewController = tabBar
                
            case.failure(let error):
                self?.alert.createAlert(error: error)
            }
        }
    }
}

// MARK: - Text Field Delegate
extension AutorizationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginText {
            passwordText.becomeFirstResponder()
        } else {
            signinPressed()
        }
        
        return true
    }
}
