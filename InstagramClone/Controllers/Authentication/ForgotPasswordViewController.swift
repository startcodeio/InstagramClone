//
//  ForgotPasswordViewController.swift
//  InstagramClone
//
//  Created by user on 13.11.2021.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class ForgotPasswordViewController: UIViewController {

    // MARK: - Views
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var recoverButton: UIButton!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Recover password"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(closeDidTapped))
        recoverButton.layer.cornerRadius = 5
    }
    
    // MARK: - Handlers
    
    @objc
    private func closeDidTapped() {
        dismiss(animated: true)
    }
    
    @IBAction func recoverButtonDidTapped(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        
        SVProgressHUD.show()
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            
            SVProgressHUD.showSuccess(withStatus: "Sended")
        }
    }
    

}
