//
//  ViewController.swift
//  VineLog
//
//  Created by Patrick Cooke on 5/19/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let backendless = Backendless.sharedInstance()
    var currentuser = BackendlessUser()
    var loginManager = LoginManager.sharedInstance
    @IBOutlet private weak var emailTextField     :UITextField!
    @IBOutlet private weak var passwordTextField  :UITextField!
    @IBOutlet private weak var signupButton       :UIButton!
    @IBOutlet private weak var loginButton        :UIButton!
    
    //MARK: - User Login Methods
    
    @IBAction private func signUpUser(button: UIButton) {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        loginManager.signUpNewUser(email, password: password)
        blankFields()
    }
    
    @IBAction private func loginUser(button: UIButton) {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        loginManager.loginUserFunc(email, password: password)
        blankFields()
    }
    
    func segueToViews() {
        print("currentuser Email: \(loginManager.currentuser.email), UserID: \(loginManager.currentuser.objectId)")
        performSegueWithIdentifier("wineCeller", sender: loginManager.currentuser)
    }
    
    
    //MARK: - Basic Validation Functions
    
    @IBAction private func textFieldChanged() {
        signupButton.enabled = false
        loginButton.enabled = false
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        if isValidLogin(email, password: password) {
            signupButton.enabled = true
            loginButton.enabled = true
        }
    }
    
    private func isValidLogin (email: String, password: String) -> Bool {
        return email.characters.count > 5 && email.characters.contains("@") && password.characters.count > 4
    }
    
    private func blankFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldChanged()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(segueToViews), name: "recvLoginInfo", object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.isFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

