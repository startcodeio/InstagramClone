//
//  ProfileViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    // MARK: - Data
    
    private var uid: String
    
    private var user: User?
    
    // MARK: - Views

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        listenUser()
    }
    
    init() {
        self.uid = Auth.auth().currentUser?.uid ?? "123"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc
    private func logOutDidTapped() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch {
            debugPrint(error)
        }
    }
    
    // MARK: - Methods
    
    private func listenUser() {
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.addSnapshotListener { document, error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    self.user = user
                    self.collectionView.reloadData()
                } catch {
                    self.showHUD(.error(text: error.localizedDescription))
                }
            } else {
                self.showHUD(.error(text: "Document not exists"))
            }
        }
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        navigationItem.title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "hand.wave"),
                                                            style: .done, target: self, action: #selector(logOutDidTapped))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProfileHeaderCollectionReusableView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "ProfileHeaderCollectionReusableView")
        collectionView.register(UINib(nibName: "PostListCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "PostListCollectionViewCell")
    }

}

extension ProfileViewController: UICollectionViewDelegate {
    
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostListCollectionViewCell", for: indexPath) as! PostListCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "ProfileHeaderCollectionReusableView",
                                                                         for: indexPath) as! ProfileHeaderCollectionReusableView
        if let user = user {
            headerView.setup(user)
        }
        return headerView
    }
    
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // Get the view for the first header
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        // Use this view to calculate the optimal size based on the collection view's width
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required, // Width is fixed
                                                  verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
    }
    
}
