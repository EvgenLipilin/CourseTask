//
//  AutorizationViewController.swift
//  Course2FinalTask
//
//  Created by Евгений on 19.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class AutorizationViewController: UIViewController {
    
    var appDelegate = AppDelegate.shared
    var apiManager = APIListManager()
    lazy var alert = AlertViewController(view: self)
    
    var loginText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Login"
        textField.textContentType = .username
        textField.keyboardType = .emailAddress
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    var passwordText: UITextField = {
        let passField = UITextField()
        passField.translatesAutoresizingMaskIntoConstraints = false
        passField.placeholder = "Password"
        passField.textContentType = .password
        passField.keyboardType = .asciiCapable
        passField.borderStyle = .roundedRect
        passField.font = .systemFont(ofSize: 14)
        passField.isSecureTextEntry = true
        passField.autocapitalizationType = .none
        passField.returnKeyType = .send
        passField.enablesReturnKeyAutomatically = true
        return passField
    }()
    
    var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.setTitle("Sign in", for: .normal)
        button.alpha = 0.3
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
    }
    
    func settingUI() {
        view.backgroundColor = .white
        let elements = [loginText,passwordText,loginButton]
        elements.forEach { (element) in
            view.addSubview(element)
        }
        let constraints = [ loginText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                            loginText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                            loginText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                            
                            passwordText.topAnchor.constraint(equalTo: loginText.bottomAnchor, constant: 8),
                            passwordText.leadingAnchor.constraint(equalTo: loginText.leadingAnchor),
                            passwordText.trailingAnchor.constraint(equalTo: loginText.trailingAnchor),
                            passwordText.heightAnchor.constraint(equalToConstant: 40 ),
                            
                            loginButton.topAnchor.constraint(equalTo: passwordText.bottomAnchor, constant: 100),
                            loginButton.leadingAnchor.constraint(equalTo: loginText.leadingAnchor),
                            loginButton.trailingAnchor.constraint(equalTo: loginText.trailingAnchor),
                            loginButton.heightAnchor.constraint(equalToConstant: 50)]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func inputText(){
        
        guard let loggin = loginText.text,
              let password = passwordText.text else {return}
        
        loginButton.isEnabled = !loggin.isEmpty && !password.isEmpty
        loginButton.alpha = loginButton.isEnabled ? 1 : 0.3
    }
    
    @objc private func signinPressed() {
        
        guard let login = loginText.text,
              let password = passwordText.text else { return }
        
        apiManager.signin(login: login, password: password) { [weak self] (result) in
            
            switch result {
            
            case.successfully(let token):
                
                APIListManager.token = token.token
                
                let storyboard = UIStoryboard(name: AppDelegate.storyBoardName, bundle: nil)
                
                guard let tabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as? TabBarController else { return }
                
                self?.appDelegate.window?.rootViewController = tabBar
                
            case.failed(let error):
                self?.alert.createAlert(error: error)
                
            }
        }
    }
}

extension AutorizationViewController: UITextFieldDelegate {
    
    func textFieldReturn(_ textField: UITextField) -> Bool {
        
        if textField == loginText {
            passwordText.becomeFirstResponder()
        } else {
            signinPressed()
        }
        
        return true
    }
    
}

