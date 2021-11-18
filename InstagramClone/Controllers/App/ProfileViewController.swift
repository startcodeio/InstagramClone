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
    
    private var posts: [Post] = []
    
    // MARK: - Views

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        listenUser()
        fetchPosts()
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
    
    private func fetchPosts() {
        let ref = Firestore.firestore().collection("posts").whereField("author.uid", isEqualTo: uid)
        ref.getDocuments { querySnapshot, error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showHUD(.error(text: "Documents not found"))
                return
            }
            
            for document in documents {
                do {
                    let post = try document.data(as: Post.self)
                    self.posts.append(post!)
                } catch {
                    print("error with \(document.documentID) \(error)")
                }
            }
            self.collectionView.reloadData()
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
        collectionView.register(UINib(nibName: "PostGridCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "PostGridCollectionViewCell")
        collectionView.register(UINib(nibName: "PostListCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "PostListCollectionViewCell")
    }

}

extension ProfileViewController: PostsListViewControllerDelegate {
    
    func updatePosts(_ posts: [Post]) {
        self.posts = posts
        collectionView.reloadData()
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PostsListViewController(posts: posts, indexPath: indexPath)
        vc.delegate = self
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostGridCollectionViewCell", for: indexPath) as! PostGridCollectionViewCell
        
        if posts.count > indexPath.row {
            let post = posts[indexPath.row]
            cell.setup(post)
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
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
