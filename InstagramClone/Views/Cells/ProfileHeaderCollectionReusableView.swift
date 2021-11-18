//
//  ProfileHeaderCollectionReusableView.swift
//  InstagramClone
//
//  Created by user on 17.11.2021.
//

import UIKit
import Kingfisher

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Views
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var postsCounterLabel: UILabel!
    
    @IBOutlet weak var followersCounterLabel: UILabel!
    
    @IBOutlet weak var followingsCounterLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var primaryButton: UIButton!
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 50
        
        primaryButton.layer.borderWidth = 1
        primaryButton.layer.borderColor = UIColor.placeholderText.cgColor
    }
    
    // MARK: - Methods
    
    func setup(_ user: User) {
        avatarImageView.kf.setImage(with: URL(string: user.avatar))
        postsCounterLabel.text = String(user.counters.posts)
        postsCounterLabel.textColor = user.counters.posts != 0 ? .label : .secondaryLabel
        followersCounterLabel.text = String(user.counters.followers)
        followersCounterLabel.textColor = user.counters.followers != 0 ? .label : .secondaryLabel
        followingsCounterLabel.text = String(user.counters.followings)
        followingsCounterLabel.textColor = user.counters.followings != 0 ? .label : .secondaryLabel
        usernameLabel.text = user.username
        bioLabel.text = user.bio
    }
    
}
