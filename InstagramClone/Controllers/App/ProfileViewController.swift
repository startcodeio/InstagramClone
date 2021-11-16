//
//  ProfileViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = Auth.auth().currentUser?.email {
            navigationItem.title = "Profile: \(email)"
        } else {
            navigationItem.title = "Profile"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "hand.wave"), style: .done, target: self, action: #selector(logOutDidTapped))
    }
    
    // MARK: - Methods
    
    @objc
    private func logOutDidTapped() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch {
            debugPrint(error)
        }
    }

}
