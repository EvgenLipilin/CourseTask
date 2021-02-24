//
//  Feed.swift
//  Course2FinalTask
//
//  Created by Евгений on 09.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher


protocol LikeImageButtonDelegate: AnyObject {
    func tapLike(post: Post)
    func tapBigLike(post: Post)
    func tapAvatarAndUserName(post: Post)
    func tapLikesButton(post: Post)
}

class FeedCell: UICollectionViewCell {
    
    //    MARK:- Properties
    weak var delegate: LikeImageButtonDelegate?
    private let apiManger = APIListManager()
    private let dateFormatter = DateFormatter()
    var post: Post? {
        didSet {
            labelLike.setTitle("Likes: \(post?.likedByCount ?? 0)", for: .normal)
            liked = post?.currentUserLikesThisPost ?? false
        }
    }
    
    private var liked: Bool = false {
        didSet {
            heartButton.tintColor = liked == true ? self.tintColor : .lightGray
        }
    }
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var imageFeed: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var datePost: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var labelLike: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGesture()
    }
    
    //    MARK: - Public Methods
    func setupCell() {
        
        guard let post = post else { return }
        let urlAvatar = URL(string: post.authorAvatar)!
        avatar.kf.setImage(with: urlAvatar)
        
        let urlPost = URL(string: post.image)!
        imageFeed.kf.setImage(with: urlPost)
        
        userName.text = post.authorUsername
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        datePost.text = dateFormatter.string(from: post.createdTime)
        
        labelLike.setTitleColor(.black, for: .normal)
        labelLike.addTarget(self, action: #selector(tapLikesButton), for: .touchUpInside)
        
        commentLabel.text = post.description
        
        heartButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        heartButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    //    MARK: - Private Methods
    private func addGesture() {
        let postImageGesture = UITapGestureRecognizer(target: self, action: #selector(bigLike(sender:)))
        postImageGesture.numberOfTapsRequired = 2
        imageFeed.isUserInteractionEnabled = true
        imageFeed.addGestureRecognizer(postImageGesture)
        
        let avatarAndGesture = UITapGestureRecognizer(target: self, action: #selector(tapAvatarAndUserName))
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(avatarAndGesture)
        
        let userNameGesture = UITapGestureRecognizer(target: self, action: #selector(tapAvatarAndUserName))
        userName.isUserInteractionEnabled = true
        userName.addGestureRecognizer(userNameGesture)
    }
    
    @objc private func tap() {
        guard let post = post else { return }
        delegate?.tapLike(post: post)
    }
    
    @objc private func tapAvatarAndUserName() {
        guard let post = post else { return }
        delegate?.tapAvatarAndUserName(post: post)
    }
    
    private func showBihLike(completion: @escaping () -> Void) {
        let likeImage = UIImage(named: "bigLike")
        let likeView = UIImageView(image: likeImage)
        likeView.center = imageFeed.center
        likeView.layer.opacity = 0
        addSubview(likeView)
        
        UIView.animate(withDuration: 0.25, animations: {
            likeView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 0.15, options: .curveEaseOut, animations: {
                likeView.alpha = 0
            }) { _ in
                completion()
            }
        }
    }
    
    @objc private func bigLike(sender: UITapGestureRecognizer) {
        guard let post = post else { return }
        guard post.currentUserLikesThisPost == false else { return }
        showBihLike() { [weak self] in
            guard let self = self else { return }
            self.delegate?.tapBigLike(post: post)
        }
    }
    
    @objc private func tapLikesButton() {
        guard let post = post else { return }
        delegate?.tapLikesButton(post: post)
    }
}
