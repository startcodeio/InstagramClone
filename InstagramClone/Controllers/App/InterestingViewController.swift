//
//  InterestingViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseFirestore

class InterestingViewController: UIViewController {
    
    // MARK: - Data
    
    private var posts: [Post] = []
    
    // MARK: - Views
    
    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let emptyView = EmptyView(type: .interesting)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        fetchPosts()
    }
    
    // MARK: - Actions
    
    @objc
    private func refreshControlDidChanged() {
        posts = []
        fetchPosts()
    }
    
    // MARK: - Methods
    
    private func fetchPosts() {
        let ref = Firestore.firestore().collection("posts")
            .order(by: "users.liked", descending: true)
        ref.getDocuments { querySnapshot, error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                self.refreshControl.endRefreshing()
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showHUD(.error(text: "Documents not found"))
                self.refreshControl.endRefreshing()
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
            self.refreshControl.endRefreshing()
            self.collectionView.reloadData()
            
            if self.posts.isEmpty {
                self.emptyView.isHidden = false
            }
        }
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        navigationItem.title = "Interesting"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PostGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostGridCollectionViewCell")
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlDidChanged), for: .valueChanged)
        
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            .isActive = true
        emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            .isActive = true
        emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            .isActive = true
        emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            .isActive = true
    }

}

// MARK: - PostsList Delegate

extension InterestingViewController: PostsListViewControllerDelegate {
    
    func updatePosts(_ posts: [Post]) {
        self.posts = posts
        collectionView.reloadData()
    }
    
}

// MARK: - CollectionView Delegate

extension InterestingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PostsListViewController(posts: posts, indexPath: indexPath)
        vc.delegate = self
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - CollectionView DataSource

extension InterestingViewController: UICollectionViewDataSource {
    
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
    
}

// MARK: - CollectionView FlowLayout Delegate

extension InterestingViewController: UICollectionViewDelegateFlowLayout {
    
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
    
}
