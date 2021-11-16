//
//  SignViewController.swift
//  InstagramClone
//
//  Created by user on 13.11.2021.
//

import UIKit

class SignInViewController: UIViewController {
    
    // MARK: - Views

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 5
    }
    
    // MARK: - Handlers
    
    @IBAction func forgotPasswordDidTapped(_ sender: UIButton) {
        let vc = ForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true)
    }
    
    
    @IBAction func loginDidTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        print("email: \(email)")
        print("password: \(password)")
    }
    
    @IBAction func signUpDidTapped(_ sender: UIButton) {
        let vc = SignUpViewController()
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true)
    }

}
