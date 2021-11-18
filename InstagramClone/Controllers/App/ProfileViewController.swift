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
    
    private var isIFollowing: Bool?
    
    // MARK: - Views
    
    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        listenUser()
        fetchMyUser()
        fetchPosts()
    }
    
    init(uid: String = Helpers.uid) {
        self.uid = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc
    private func menuDidTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [unowned self] _ in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true)
            } catch {
                debugPrint(error)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        navigationController?.present(alert, animated: true)
    }
    
    @objc
    private func refreshControlChanged() {
        DispatchQueue.main.asyncAfter(deadline: (.now() + 0.5)) { [weak self] in
            self?.refreshControl.endRefreshing()
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
    
    private func fetchMyUser() {
        let ref = Firestore.firestore().collection("users").document(Helpers.uid)
        ref.getDocument { document, error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            if let document = document, document.exists {
                do {
                    let myUser = try document.data(as: User.self)
                    self.isIFollowing = myUser!.followingUsers.contains(self.uid)
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
        let ref = Firestore.firestore().collection("posts")
            .whereField("author.uid", isEqualTo: uid)
            .order(by: "publishDate", descending: true)
        ref.addSnapshotListener { querySnapshot, error in
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
        
        if Helpers.uid == uid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                                style: .done, target: self, action: #selector(menuDidTapped))
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProfileHeaderCollectionReusableView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "ProfileHeaderCollectionReusableView")
        collectionView.register(UINib(nibName: "PostGridCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "PostGridCollectionViewCell")
        collectionView.register(UINib(nibName: "PostListCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "PostListCollectionViewCell")
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlChanged), for: .valueChanged)
    }

}

// MARK: - ProfileHeader Delegate

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    
    func editProfileButtonAction() {
        print("open edit file")
    }
    
    func followButtonAction() {
        guard let isIFollowing = isIFollowing else { return }
        let changeArray = isIFollowing ? FieldValue.arrayRemove([uid]) : FieldValue.arrayUnion([uid])
        Firestore.firestore().collection("users").document(Helpers.uid).updateData(["followingUsers": changeArray]) { error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            self.incrementUsersCounters(startFollowing: !isIFollowing)
            self.createActivity(startFollowing: !isIFollowing)
            self.isIFollowing?.toggle()
            self.collectionView.reloadData()
        }
    }
    
    // Helpers
    
    private func incrementUsersCounters(startFollowing: Bool) {
        Firestore.firestore().collection("users").document(Helpers.uid)
            .updateData(["counters.followings": FieldValue.increment(Int64(startFollowing ? 1 : -1))])
        Firestore.firestore().collection("users").document(uid)
            .updateData(["counters.followers": FieldValue.increment(Int64(startFollowing ? 1 : -1))])
    }
    
    private func createActivity(startFollowing: Bool) {
        let ref = Firestore.firestore().collection("activities").document()
        
        let activity = Activity(id: ref.documentID,
                                author: Helpers.author,
                                linkId: uid,
                                toUid: uid,
                                type: ActivityType.follow.rawValue,
                                isRead: false,
                                publishDate: Timestamp(date: Date()))
        if startFollowing {
            do {
                try ref.setData(from: activity)
            } catch {
                showHUD(.error(text: "Activity not created! \(error.localizedDescription)"))
            }
        }
    }
    
}

// MARK: - PostsList Delegate

extension ProfileViewController: PostsListViewControllerDelegate {
    
    func updatePosts(_ posts: [Post]) {
        self.posts = posts
        collectionView.reloadData()
    }
    
}

// MARK: - CollectionView Delegate

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PostsListViewController(posts: posts, indexPath: indexPath)
        vc.delegate = self
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - CollectionView DataSource

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
            headerView.setup(user, isIFollowing: isIFollowing)
            headerView.delegate = self
        }
        return headerView
    }
    
}

// MARK: - CollectionView FlowLayout Delegate

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
