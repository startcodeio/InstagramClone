//
//  EmptyView.swift
//  InstagramClone
//
//  Created by user on 19.11.2021.
//

import Foundation
import UIKit

enum EmptyViewType {
    case feed
    case interesting
    case activities
}

class EmptyView: UIView {
    
    // MARK: - Views
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "feed")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Empty view title is here"
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    init(type: EmptyViewType) {
        super.init(frame: .zero)
        setupLayout()
        
        switch type {
        case .feed:
            imageView.image = UIImage(named: "feed")
            titleLabel.text = "Follow users and you will see their posts here"
        case.interesting:
            imageView.image = UIImage(named: "interesting")
            titleLabel.text = "Here will displayed user's post all around the world"
        case .activities:
            imageView.image = UIImage(named: "activities")
            titleLabel.text = "No activities yet. Here you will see your activities."
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        backgroundColor = .systemBackground
        isHidden = true
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            .isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
            .isActive = true
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16)
            .isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
            .isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            .isActive = true
    }
    
}
