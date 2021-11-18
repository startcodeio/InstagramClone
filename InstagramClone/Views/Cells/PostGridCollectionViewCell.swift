//
//  PostCollectionViewCell.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit

class PostGridCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.kf.indicatorType = .activity
    }
    
    func setup(_ post: Post) {
        imageView.kf.setImage(with: URL(string: post.image))
    }

}
