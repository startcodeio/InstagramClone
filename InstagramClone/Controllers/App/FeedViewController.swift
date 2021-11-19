//
//  FeedViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UIViewController {
    
    // MARK: - Data
    
    private var models: [Post] = []
    
    private var followingUsers: [String] = []
    
    // MARK: - Views
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let emptyView = EmptyView(type: .feed)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        
        getMyUser { user in
            self.followingUsers = user?.followingUsers ?? []
            self.fetchPosts()
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func refreshControlDidChanged() {
        models = []
        fetchPosts()
    }
    
    // MARK: - Methods
    
    private func fetchPosts() {
        followingUsers = Array(followingUsers.prefix(10))
        
        if followingUsers.isEmpty {
            emptyView.isHidden = false
            return
        }
        
        Firestore.firestore().collection("posts").whereField("author.uid", in: followingUsers)
            .getDocuments { querySnapshot, error in
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
                    self.models.append(post!)
                } catch {
                    print("error with \(document.documentID) \(error)")
                }
            }
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    private func getMyUser(completion: @escaping(User?) -> Void) {
        Firestore.firestore().collection("users").document(Helpers.uid).getDocument { document, error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                completion(nil)
            }
            
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch {
                    self.showHUD(.error(text: error.localizedDescription))
                    completion(nil)
                }
            } else {
                self.showHUD(.error(text: "User not found"))
                completion(nil)
            }
        }
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        navigationItem.title = "Feed"
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PostTableViewCell")
        tableView.refreshControl = refreshControl
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

// MARK: - PostTable Delegate

extension FeedViewController: PostTableViewCellDelegate {
    
    func avatarAction(post: Post) {
        let vc = ProfileViewController(uid: post.author.uid)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeAction(post: Post, status: Bool) {
        let ref = Firestore.firestore().collection("posts").document(post.id)
        let changeArray = status ? FieldValue.arrayUnion([Helpers.uid]) : FieldValue.arrayRemove([Helpers.uid])
        
        ref.updateData(["users.liked": changeArray]) { error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            var mutablePost = post
            if status {
                mutablePost.users.liked.append(Helpers.uid)
                self.createActivity(post: post)
            } else {
                mutablePost.users.liked.removeAll(where: { $0 == Helpers.uid })
            }
            
            for (index, model) in self.models.enumerated() {
                if model.id == post.id {
                    self.models[index] = mutablePost
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func commentAction(post: Post) {
        print("comment")
    }
    
    func saveAction(post: Post, status: Bool) {
        let ref = Firestore.firestore().collection("posts").document(post.id)
        let changeArray = status ? FieldValue.arrayUnion([Helpers.uid]) : FieldValue.arrayRemove([Helpers.uid])
        
        ref.updateData(["users.saved": changeArray]) { error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            var mutablePost = post
            if status {
                mutablePost.users.saved.append(Helpers.uid)
            } else {
                mutablePost.users.saved.removeAll(where: { $0 == Helpers.uid })
            }
            
            for (index, model) in self.models.enumerated() {
                if model.id == post.id {
                    self.models[index] = mutablePost
                }
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    // Helper
    
    private func createActivity(post: Post) {
        let ref = Firestore.firestore().collection("activities").document()
        let activity = Activity(id: ref.documentID,
                                author: Helpers.author,
                                linkId: post.id,
                                toUid: post.author.uid,
                                type: ActivityType.like.rawValue,
                                isRead: false,
                                publishDate: Timestamp(date: Date()))
        do {
            try ref.setData(from: activity)
        } catch {
            showHUD(.error(text: "Activity not created! \(error.localizedDescription)"))
        }
    }
}

// MARK: - TableView DataSource

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        if models.count > indexPath.row {
            let post = models[indexPath.row]
            cell.setup(post)
            cell.delegate = self
        }
        return cell
    }
    
    
}
