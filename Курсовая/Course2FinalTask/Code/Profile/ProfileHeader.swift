//
//  ProfileHeader.swift
//  Course2FinalTask
//
//  Created by Евгений on 09.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

let identifierHeader = "ProfileHeaderCell"

protocol FollowUnfollowDelegate: AnyObject {
    func tapFollowUnfollowButton(user: User)
}

final class ProfileHeaderCell: UICollectionViewCell {
    
    //    MARK: - Public Properties
    weak var delegate: FollowUnfollowDelegate?
    
    var currentUser: User?
    var user: User? {
        didSet {
            if user?.username == "ivan1975" {
                followUnfollowButton.isHidden = true
            } else {
                followUnfollowButton.isHidden = false
                
                if user?.currentUserFollowsThisUser == true {
                    followUnfollowButton.setTitle(NSLocalizedString("Unfollow", tableName: "Localizable", bundle: .main, value: "", comment: ""), for: .normal)
                } else {
                    followUnfollowButton.setTitle(NSLocalizedString("Follow", tableName: "Localizable", bundle: .main, value: "", comment: ""), for: .normal)
                }
            }
        }
    }
    
    let followersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    let followingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
   
    //    MARK: - Private Properties
   private let followUnfollowButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 1, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        button.layer.cornerRadius = 7
        button.isHidden = true
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel(frame: .init(x: 0, y: 0, width: 100, height: 10))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 35
        return image
    }()
    
    //    MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Public Methods
    func createCell() {
        guard let user = user else { return }
        nameLabel.text = user.fullName
        followersButton.setTitle(NSLocalizedString("Followers:", tableName: "Localizable", bundle: .main, value: "", comment: "") + " \(user.followsCount)", for: .normal)
        followingButton.setTitle(NSLocalizedString("Following:", tableName: "Localizable", bundle: .main, value: "", comment: "") + " \(user.followedByCount)", for: .normal)
       
        if TabBarController.offlineMode == false {
        let url = URL(string: user.avatar)
            avatarImageView.kf.setImage(with: url)
        } else {
            guard let imadeData = user.avatarData else { return }
            avatarImageView.image = UIImage(data: imadeData)
        }
        
        followUnfollowButton.addTarget(self, action: #selector(tapFollowUnfollow), for: .touchUpInside)
    }
    
    //    MARK: - Private Methods
    @objc private func tapFollowUnfollow() {
        guard let user = user else { return }
        delegate?.tapFollowUnfollowButton(user: user)
    }
    
    private func configureUI() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(followersButton)
        addSubview(followingButton)
        addSubview(followUnfollowButton)
        
        let constraints = [avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                           avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           avatarImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
                           avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
                           
                           nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
                           nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
                           
                           followersButton.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
                           followersButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
                           
                           followingButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
                           followingButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
                           
                           followUnfollowButton.topAnchor.constraint(equalTo: nameLabel.topAnchor),
                           followUnfollowButton.trailingAnchor.constraint(equalTo: followingButton.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
