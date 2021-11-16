//
//  SignUpViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

protocol SignUpDelegate: AnyObject {
    func signUpSuccessfully()
}

class SignUpViewController: UIViewController {
    
    // MARK: - Data
    
    weak var delegate: SignUpDelegate?
    
    // MARK: - Views
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Create new account"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(closeDidTapped))
        
        avatarImageView.layer.cornerRadius = 50
        signUpButton.layer.cornerRadius = 5
    }
    
    // MARK: - Actions
    
    @objc
    private func closeDidTapped() {
        dismiss(animated: true)
    }
    
    @IBAction
    func signUpButtonDidTapped(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            SVProgressHUD.dismiss()
            self?.dismiss(animated: true)
            self?.delegate?.signUpSuccessfully()
        }
    }
    

}
