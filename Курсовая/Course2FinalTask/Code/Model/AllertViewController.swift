//
//  AllertView.swift
//  Course2FinalTask
//
//  Created by Евгений on 12.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    let inputViewControllers: UIViewController
    
    init(view: UIViewController) {
        self.inputViewControllers = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createAlert(error: Error?) {
        
        var title = "Unknown error!"
        var massege = "Please, try again later."
        
        if TabBarController.offlineMode == true {
            title = "Offline mode"
            massege = ""
        }
        
        if let error = error as? ErrorManager {
            title = error.rawValue
        }
        
        let alert = UIAlertController(title: title, message: massege, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        
        inputViewControllers.present(alert, animated: true, completion: nil)
    }
}
