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
    
    private let showIndexPath: IndexPath
    
    weak var delegate: PostsListViewControllerDelegate?
    
    // MARK: - Views

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    
    init(posts: [Post], indexPath: IndexPath) {
        self.posts = posts
        self.showIndexPath = indexPath
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
        tableView.scrollToRow(at: showIndexPath, at: .top, animated: false)
    }

}

// MARK: - PostTable Delegate

extension PostsListViewController: PostTableViewCellDelegate {
    
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
            
            for (index, model) in self.posts.enumerated() {
                if model.id == post.id {
                    self.posts[index] = mutablePost
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
