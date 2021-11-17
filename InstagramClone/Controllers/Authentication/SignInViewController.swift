//
//  SignViewController.swift
//  InstagramClone
//
//  Created by user on 13.11.2021.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class SignInViewController: UIViewController {
    
    // MARK: - Views

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 5
        
        if Auth.auth().currentUser != nil {
            navigateToApp()
        }
    }
    
    // MARK: - Handlers
    
    @IBAction
    func forgotPasswordDidTapped(_ sender: UIButton) {
        let vc = ForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true)
    }
    
    
    @IBAction
    func loginDidTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        showHUD()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let error = error {
                self?.showHUD(.error(text: error.localizedDescription))
                return
            }
            self?.showHUD(.dismiss)
            self?.navigateToApp()
        }
    }
    
    @IBAction
    func signUpDidTapped(_ sender: UIButton) {
        let vc = SignUpViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true)
    }
    
    // MARK: - Methods
    
    private func navigateToApp() {
        let vc = TabbarController()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true)
    }

}

extension SignInViewController: SignUpDelegate {
    
    func signUpSuccessfully() {
        navigateToApp()
    }
    
}
