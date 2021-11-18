//
//  ActivityTableViewCell.swift
//  InstagramClone
//
//  Created by user on 18.11.2021.
//

import UIKit

enum ActivityType: Int {
    case follow = 0
    case like = 1
    case comment = 2
}

class ActivityTableViewCell: UITableViewCell {
    
    // MARK: - Views

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var unreadView: UIView!
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 22
        unreadView.layer.cornerRadius = 4
        avatarImageView.kf.indicatorType = .activity
    }
    
    // MARK: - Methods
    
    func setup(_ activity: Activity) {
        avatarImageView.kf.setImage(with: URL(string: activity.author.avatar))
        unreadView.isHidden = activity.isRead
        
        var activityText = ""
        let activityType = ActivityType(rawValue: activity.type)
        
        switch activityType {
        case .follow: activityText = " start following you. "
        case .like: activityText = " like your post. "
        case .comment: activityText = " comment your post. "
        case .none: activityText = " can't find notification type. "
        }
        
        let attributedText = NSMutableAttributedString(
            string: activity.author.username,
            attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.label])
        
        attributedText.append(NSAttributedString(
            string: activityText,
            attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.label]))
        
        attributedText.append(NSAttributedString(
            string: "3d",
            attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel]))
        
        informationLabel.attributedText = attributedText
    }
    
}
