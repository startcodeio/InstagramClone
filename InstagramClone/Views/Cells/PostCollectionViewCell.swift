//
//  PostCollectionViewCell.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .green
    }

}
