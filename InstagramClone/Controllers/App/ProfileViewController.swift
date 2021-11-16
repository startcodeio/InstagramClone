//
//  ProfileViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Profile @username"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "hand.wave"), style: .done, target: self, action: #selector(logOutDidTapped))
    }
    
    // MARK: - Methods
    
    @objc
    private func logOutDidTapped() {
        dismiss(animated: true)
    }

}
