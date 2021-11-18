//
//  PostTableViewCell.swift
//  InstagramClone
//
//  Created by user on 18.11.2021.
//

import UIKit
import FirebaseAuth

protocol PostTableViewCellDelegate: AnyObject {
    func avatarAction(post: Post)
    func likeAction(post: Post, status: Bool)
    func commentAction(post: Post)
    func saveAction(post: Post, status: Bool)
}

class PostTableViewCell: UITableViewCell {
    
    // MARK: - Data
    
    private var post: Post?
    
    weak var delegate: PostTableViewCellDelegate?
    
    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var commentImageView: UIImageView!
    
    @IBOutlet weak var savedImageView: UIImageView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.kf.indicatorType = .activity
        postImageView.kf.indicatorType = .activity
        
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarDidTapped)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(likeDidTapped))
        doubleTap.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(doubleTap)
        likeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeDidTapped)))
        commentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentDidTapped)))
        savedImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveDidTapped)))
    }
    
    // MARK: - Actions
    
    @objc
    private func avatarDidTapped() {
        guard let post = post else { return }
        delegate?.avatarAction(post: post)
    }
    
    @objc private func likeDidTapped() {
        guard let post = post,
              let uid = Auth.auth().currentUser?.uid else { return }
        
        delegate?.likeAction(post: post, status: !post.users.liked.contains(uid))
    }
    
    @objc private func commentDidTapped() {
        guard let post = post else { return }
        delegate?.commentAction(post: post)
    }
    
    @objc
    private func saveDidTapped() {
        guard let post = post,
              let uid = Auth.auth().currentUser?.uid else { return }
        
        delegate?.saveAction(post: post, status: !post.users.saved.contains(uid))
    }
    
    // MARK: - Methods
    
    func setup(_ post: Post) {
        self.post = post
        avatarImageView.kf.setImage(with: URL(string: post.author.avatar))
        usernameLabel.text = post.author.username
        postImageView.kf.setImage(with: URL(string: post.image))
        infoLabel.text = "\(post.users.liked.count) likes and \(post.users.commented.count) comments"
        descriptionLabel.text = post.description
        
        let uid = Auth.auth().currentUser?.uid ?? "123"
        
        let isILiked = post.users.liked.contains(uid)
        likeImageView.image = UIImage(systemName: isILiked ? "heart.fill" : "heart")
        
        let isISaved = post.users.saved.contains(uid)
        savedImageView.image = UIImage(systemName: isISaved ? "bookmark.fill" : "bookmark")
    }
    
}
