//
//  SignUpViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit

class SignUpViewController: UIViewController {
    
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
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        print("username: \(username)")
        print("email: \(email)")
        print("password: \(password)")
    }
    

}
