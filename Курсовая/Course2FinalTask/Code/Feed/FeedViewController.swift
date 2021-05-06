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
    
    //    MARK:- Private Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var block = BlockViewController(view: (tabBarController?.view)!)
    private lazy var alert = AlertViewController(view: self)
    private var postsArray: [Post]? {
        didSet {
            let posts = fetchFeedFromCoreData()
            if posts.isEmpty {
                saveFeedInCoreData(posts: postsArray!)
            }
        }
    }
    private var apiManger = APIListManager()
    private var dataManager: CoreDataInstagram {
        AppDelegate.shared.dataManager
    }
    
    //        MARK:- Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        collectionView.register(UINib(nibName: "Feed", bundle: nil), forCellWithReuseIdentifier: "FeedCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    //    Обновляет UI и скроллит в начало ленты при публикации новой фотографии
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if TabBarController.offlineMode == false {
            createPostsArray(token: APIListManager.token, blockAnimation: true)
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
    }
    
    //    MARK: - Private Methods
    
    //    Создает массив постов
    private func createPostsArray(token: String, blockAnimation: Bool) {
        if blockAnimation == true {
            block.startAnimating()
        }
        apiManger.feed(token: token) { [weak self] (result) in
            guard let self = self else { return }
            
            if blockAnimation == true {
                self.block.stopAnimating()
            }
            
            switch result {
            case .success(let posts):
                self.postsArray = posts
                self.collectionView.reloadData()
                
            case .failure(let error):
                switch error {
                
                case .offlineMode:
                    self.postsArray = self.fetchFeedFromCoreData()
                    self.collectionView.reloadData()
                
                default:
                    return
                }
                
                self.alert.createAlert(error: error)
            }
        }
    }
    
    private func saveFeedInCoreData(posts: [Post]) {
        dataManager.saveFeedInCoreData(for: Feed.self, posts: posts)
    }
    
    private func fetchFeedFromCoreData() -> [Post] {
        dataManager.fetchFeed(for: Feed.self)
    }
    
    //    Cоздание VC и переход в профиль пользователя
    private func goToUserProfile(user: User) {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { alert.createAlert(error: nil)
            return }
        profileVC.user = user
        show(profileVC, sender: nil)
    }
}

//    MARK:- Data Source and Delegate
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
        CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
}

//    MARK: - Like Image Button Delegate
extension FeedViewController: LikeImageButtonDelegate {
    
    //    Создает массив пользователей, которые лайкнули публикацию и отображает их
    func tapLikesButton(post: Post) {
        
        block.startAnimating()
        apiManger.usersLikedPost(token: APIListManager.token, id: post.id, completion: { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let users):
                self.block.stopAnimating()
                let vc = FollowersTableViewController(usersArray: users, titleName: "Likes")
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                self.alert.createAlert(error: error)
            }
        })
    }
    
    //    Переход на страницу пользователя при нажатии на фото или имя
    func tapAvatarAndUserName(post: Post) {
        
        block.startAnimating()
        apiManger.userID(token: APIListManager.token, id: post.author) { [weak self] (result) in
            guard let self = self else { return }
            self.block.stopAnimating()
            
            switch result {
            case .success(let user):
                self.goToUserProfile(user: user)
                
            case .failure(let error):
                self.alert.createAlert(error: error)
            }
        }
    }
    
    //    Ставит лайк при двойном нажатии на фото
    func tapBigLike(post: Post) {
        apiManger.likePost(token: APIListManager.token, id: post.id) { [weak self] _ in
            guard let self = self else { return }
            
            self.createPostsArray(token: APIListManager.token, blockAnimation: false)
        }
    }
    
    //    Ставит/убирает лайк при нажатии на сердце
    func tapLike(post: Post) {
        
        if post.currentUserLikesThisPost {
            apiManger.unlikePost(token: APIListManager.token, id: post.id) { [weak self] _ in
                guard let self = self else { return }
                
                self.createPostsArray(token: APIListManager.token, blockAnimation: false)
            }
        } else {
            apiManger.likePost(token: APIListManager.token, id: post.id) { [weak self] _ in
                guard let self = self else { return }
                
                self.createPostsArray(token: APIListManager.token, blockAnimation: false)
            }
        }
    }
}

// MARK: - Add New Post Delegate
extension FeedViewController: AddNewPostDelegate {
    
    //    Обновляет UI и скроллит в начало ленты при публикации новой фотографии
    func updateFeedUI() {
        createPostsArray(token: APIListManager.token, blockAnimation: false)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
    }
}
