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
    
    private var posts: [Post] = []
    
    private var followingUsers: [String] = []
    
    // MARK: - Views
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMyUser { user in
            self.followingUsers = user?.followingUsers ?? []
            self.fetchPosts()
        }

        navigationItem.title = "Feed"
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PostTableViewCell")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlDidChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc
    private func refreshControlDidChanged() {
        posts = []
        fetchPosts()
    }
    
    // MARK: - Methods
    
    private func fetchPosts() {
        followingUsers = Array(followingUsers.prefix(10))
        
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
                    self.posts.append(post!)
                } catch {
                    print("error with \(document.documentID) \(error)")
                }
            }
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    private func getMyUser(completion: @escaping(User?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showHUD(.error(text: "Your user uid not found"))
            completion(nil)
            return
        }
        
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.getDocument { document, error in
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

}

// MARK: - PostTable Delegate

extension FeedViewController: PostTableViewCellDelegate {
    
    func avatarAction(post: Post) {
        let vc = ProfileViewController(uid: post.author.uid)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeAction(post: Post, status: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("posts").document(post.id)
        let changeArray = status ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid])
        
        ref.updateData(["users.liked": changeArray]) { error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            var mutablePost = post
            if status {
                mutablePost.users.liked.append(uid)
            } else {
                mutablePost.users.liked.removeAll(where: { $0 == uid })
            }
            
            for (index, model) in self.posts.enumerated() {
                if model.id == post.id {
                    self.posts[index] = mutablePost
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func commentAction(post: Post) {
        print("comment")
    }
    
    func saveAction(post: Post, status: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("posts").document(post.id)
        let changeArray = status ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid])
        
        ref.updateData(["users.saved": changeArray]) { error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            var mutablePost = post
            if status {
                mutablePost.users.saved.append(uid)
            } else {
                mutablePost.users.saved.removeAll(where: { $0 == uid })
            }
            
            for (index, model) in self.posts.enumerated() {
                if model.id == post.id {
                    self.posts[index] = mutablePost
                }
            }
            
            self.tableView.reloadData()
        }
        
    }
    
}

// MARK: - TableView DataSource

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        if posts.count > indexPath.row {
            let post = posts[indexPath.row]
            cell.setup(post)
            cell.delegate = self
        }
        return cell
    }
    
    
}
