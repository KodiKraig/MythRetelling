//
//  LoginViewController.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/8/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Constants
    
    fileprivate struct LocalConstants {
        static let SegueToHome = "ShowMain"
        static let UserNameKey = "Username"
        static let PasswordKey = "Password"
    }

    // MARK: IBOutlets

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    // MARK: IBActions

    @IBAction func loginBtnPressed(_ sender: UIButton) {
        if checkTxtFieldsFilled() {
            login()
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        if checkTxtFieldsFilled() {
            signUp()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Constants.PrimaryColor
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.text = UserDefaults.standard.value(forKey: LocalConstants.UserNameKey) as? String
        passwordTextField.text = UserDefaults.standard.value(forKey: LocalConstants.PasswordKey) as? String
    }
    
    // MARK: Sign-in/login
    
    fileprivate func checkTxtFieldsFilled() -> Bool {
        if usernameTextField.text!.removeWhiteSpace().isEmpty {
            displayAlert(self, title: "Error", message: "No username entered")
            return false
        } else if passwordTextField.text!.removeWhiteSpace().isEmpty {
            displayAlert(self, title: "Error", message: "No password entered")
            return false
        }
        return true
    }
    
    fileprivate func login() {
        Backendless.sharedInstance().userService.login(usernameTextField.text!.removeWhiteSpace(), password: passwordTextField.text!.removeWhiteSpace(), response: { (loggedInUser) in
            Backendless.sharedInstance().userService.setStayLoggedIn(true)
            UserDefaults.standard.set(self.usernameTextField.text!.removeWhiteSpace(), forKey: LocalConstants.UserNameKey)
            UserDefaults.standard.set(self.passwordTextField.text!.removeWhiteSpace(), forKey: LocalConstants.PasswordKey)
            self.performSegue(withIdentifier: LocalConstants.SegueToHome, sender: nil)
        }, error: { (fault) in
            if let errorMsg = fault?.message {
                displayAlert(self, title: "Error", message: "Login error. Fault: \(errorMsg)")
            } else {
                displayAlert(self, title: "Error", message: "Unknown login error. Please try again.")
            }
        })
    }
    
    fileprivate func signUp() {
        let user = BackendlessUser(properties: ["name":usernameTextField.text!.removeWhiteSpace(),
                                                "password":passwordTextField.text!.removeWhiteSpace()])
        Backendless.sharedInstance().userService.register(user, response: { (newUser) in
            self.login()
        }, error: { (fault) in
            if let errorDesc = fault?.message {
                displayAlert(self, title: "Error", message: "Registration error. Fault: \(errorDesc)")
            } else {
                displayAlert(self, title: "Error", message: "Unknown registration error. Please try again.")
            }
        })
    }
}
