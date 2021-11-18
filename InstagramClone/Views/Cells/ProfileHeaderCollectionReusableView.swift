//
//  ProfileHeaderCollectionReusableView.swift
//  InstagramClone
//
//  Created by user on 17.11.2021.
//

import UIKit
import FirebaseAuth
import Kingfisher

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func followButtonAction()
    func editProfileButtonAction()
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Data
    
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    private var user: User?
    
    // MARK: - Views
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var postsCounterLabel: UILabel!
    
    @IBOutlet weak var followersCounterLabel: UILabel!
    
    @IBOutlet weak var followingsCounterLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var primaryButton: UIButton!
    
    @IBOutlet weak var postsStackView: UIStackView!
    
    @IBOutlet weak var followersStackView: UIStackView!
    
    @IBOutlet weak var followingsStackView: UIStackView!
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 50
        
        primaryButton.layer.borderWidth = 1
        primaryButton.layer.borderColor = UIColor.placeholderText.cgColor
    }
    
    // MARK: - Actions
    
    @IBAction func primaryButtonDidTapped(_ sender: Any) {
        guard let user = user,
              let myUid = Auth.auth().currentUser?.uid else { return }
        if user.uid == myUid {
            delegate?.editProfileButtonAction()
        } else {
            delegate?.followButtonAction()
        }
    }
    
    // MARK: - Methods
    
    func setup(_ user: User, isIFollowing: Bool?) {
        self.user = user
        avatarImageView.kf.setImage(with: URL(string: user.avatar))
        postsCounterLabel.text = String(user.counters.posts)
        postsCounterLabel.textColor = user.counters.posts != 0 ? .label : .secondaryLabel
        followersCounterLabel.text = String(user.counters.followers)
        followersCounterLabel.textColor = user.counters.followers != 0 ? .label : .secondaryLabel
        followingsCounterLabel.text = String(user.counters.followings)
        followingsCounterLabel.textColor = user.counters.followings != 0 ? .label : .secondaryLabel
        usernameLabel.text = user.username
        bioLabel.text = user.bio
        setupPrimaryButton(uid: user.uid, isIFollowing: isIFollowing)
    }
    
    private func setupPrimaryButton(uid: String, isIFollowing: Bool?) {
        let myUid = Auth.auth().currentUser?.uid ?? "123"
        let isMe = uid == myUid
        if isMe {
            primaryButton.setTitle("Edit profile", for: .normal)
        } else {
            if let isIFollowing = isIFollowing {
                primaryButton.setTitle(isIFollowing ? "Following" : "Follow", for: .normal)
                primaryButton.setTitleColor(isIFollowing ? .label : .white, for: .normal)
                primaryButton.backgroundColor = isIFollowing ? .systemBackground : .systemBlue
            } else {
                primaryButton.setTitle("Loading...", for: .normal)
            }
        }
    }
    
}
