//
//  PostsListViewController.swift
//  InstagramClone
//
//  Created by user on 18.11.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol PostsListViewControllerDelegate: AnyObject {
    func updatePosts(_ posts: [Post])
}

class PostsListViewController: UIViewController {
    
    // MARK: - Data
    
    private var posts: [Post] = []
    
    weak var delegate: PostsListViewControllerDelegate?
    
    // MARK: - Views

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    
    init(posts: [Post]) {
        self.posts = posts
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        delegate?.updatePosts(posts)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Posts"
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PostTableViewCell")
    }

}

extension PostsListViewController: UITableViewDataSource {
    
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

extension PostsListViewController: PostTableViewCellDelegate {
    
    func avatarAction(post: Post) {
        print("open profile")
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
