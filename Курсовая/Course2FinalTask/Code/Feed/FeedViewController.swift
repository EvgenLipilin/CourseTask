//
//  Feeds.swift
//  Course2FinalTask
//
//  Created by Евгений on 09.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class FeedViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var block = BlockViewController(view: (tabBarController?.view)!)
    private lazy var alert = AlertViewController(view: self)
    private var postsArray: [Post]?
    private var usersLikedPost: [User]?
    private var apiManger = APIListManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        collectionView.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedCell")
        collectionView.dataSource = self
        collectionView.delegate = FeedCell() as? UICollectionViewDelegate
    }
    
    
    //    Обновляет UI и скроллит в начало ленты при новой публикации
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        createPostsArrayWithBlock(token: APIListManager.token)
    }
    
    //    Создает массив постов без блокировки UI для лайков
    func createPostsArrayWithoutBlock(token: String) {
        apiManger.feed(token: token) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .successfully(let posts):
                self.postsArray = posts
                self.collectionView.reloadData()
                
            case .failed(let error):
                self.alert.createAlert(error: error)
            }
        }
    }
    
    
    //    Создает массив постов с блокировкой UI
    private func createPostsArrayWithBlock(token: String) {
        block.startAnimating()
        apiManger.feed(token: token) { [weak self] (result) in
            guard let self = self else { return }
            self.block.stopAnimating()
            
            switch result {
            case .successfully(let posts):
                self.postsArray = posts
                self.collectionView.reloadData()
                
            case .failed(let error):
                self.alert.createAlert(error: error)
            }
        }
    }
    
    //    Cоздание ViewCont и переход в профиль пользователя
    private func goToUserProfile(user: User) {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { alert.createAlert(error: nil)
            return }
        profileVC.user = user
        show(profileVC, sender: nil)
    }
}

//    MARK:- DataSource and Delegate
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let array = postsArray else { return 0 }
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCell
        guard let array = postsArray else { return UICollectionViewCell() }
        let post = array[indexPath.item]
        cell.post = post
        cell.setupCell()
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.bounds.width, height: 600)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}


extension FeedViewController: LikeImageButtonDelegate {
    func tapLiked(post: Post) {
        
        if post.currentUserLikesThisPost {
            apiManger.unlikePost(token: APIListManager.token, id: post.id) { [weak self] _ in
                guard let self = self else { return }
                
                self.createPostsArrayWithoutBlock(token: APIListManager.token)
            }
        } else {
            apiManger.likePost(token: APIListManager.token, id: post.id) { [weak self] _ in
                guard let self = self else { return }
                
                self.createPostsArrayWithoutBlock(token: APIListManager.token)
            }
        }
    }
    
    func tapBigLike(post: Post) {
        apiManger.likePost(token: APIListManager.token, id: post.id) { [weak self] _ in
            guard let self = self else { return }
            
            self.createPostsArrayWithoutBlock(token: APIListManager.token)
        }
    }
    
    
    //Показывает всех лайкнушвших пост юзеров
    func likesLabelTapped(post: Post) {
        
        block.startAnimating()
        apiManger.usersLikedPost(token: APIListManager.token, id: post.id, completion: { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .successfully(let users):
                self.block.stopAnimating()
                let vc = FollowersTableViewController(usersArray: users, titleName: "Likes")
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failed(let error):
                self.alert.createAlert(error: error)
            }
        })
    }
    
    //    Создает массив пользователей, которые лайкнули публикацию и показывает их
    func tapLikes(post: Post) {
        
        block.startAnimating()
        self.postClass.usersLikedPost(with: post.id, queue: DispatchQueue.global()) { [weak self] (usersArray) in
            guard let self = self else { return }
            guard usersArray != nil else { return }
            self.usersLikedPost = usersArray
            guard let array = self.usersLikedPost else { return }
            
            self.userClass.user(with: post.author, queue: .global()) { [weak self] (user) in
                guard let self = self else { return }
                guard user != nil else { return }
                self.user = user
                guard let myUser = self.user else { return }
                
                DispatchQueue.main.async {
                    self.block.stopAnimating()
                    self.navigationController?.pushViewController(FollowersTableViewController(usersArray: array, titleName: "Likes", user: myUser), animated: true)
                }
            }
        }
    }
    
    //    Открывает профиль пользователя при нажатии на его фото или имя в ленте постов
    func tapAvatarAndUserName(post: Post) {
        block.startAnimating()
        
        apiManger.userID(token: APIListManager.token, id: post.author) { [weak self] (result) in
            guard let self = self else { return }
            self.block.stopAnimating()
            
            switch result {
            case .successfully(let user):
                self.goToUserProfile(user: user)
                
            case .failed(let error):
                self.alert.createAlert(error: error)
            }
        }
        
        //    Метод проставки лайка по двойном нажатии на изображение поста
        
        //    Ставит или убирает лайк при нажатии на кнопку "сердце"
        func tapLiked(post: Post) {
            
            if post.currentUserLikesThisPost {
                apiManger.unlikePost(token: APIListManager.token, id: post.id) { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.createPostsArrayWithoutBlock(token: APIListManager.token)
                }
            } else {
                apiManger.likePost(token: APIListManager.token, id: post.id) { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.createPostsArrayWithoutBlock(token: APIListManager.token)
                }
            }
        }
        
    }
    //    Обновляет UI и скроллит в начало ленты при публикации новой фотографии
    func updateFeedUI() {
        createPostsArrayWithoutBlock(token: APIListManager.token)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
    }
}
