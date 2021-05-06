//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Евгений on 26.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var block = BlockViewController(view: (tabBarController?.view)!)
    private lazy var alert = AlertViewController(view: self)
    private var postsOfCurrentUser: [Post]?
    private let apiManger = APIListManager()
    private var appDelegate = AppDelegate.shared
    private let keychain: KeychainProtocol = KeychainManager()
    private var dataManager: CoreDataInstagram {
        AppDelegate.shared.dataManager
    }
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCurrentUserAndPosts()
        
        collectionView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCell")
        collectionView.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifierHeader)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    //    Обновляет массив постов при публикации новой фотографии
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        createPostsArray()
    }
    
    //    MARK: - Private Methods
    
    //    Создает текущего пользователя и массив его постов
    private func createCurrentUserAndPosts() {
        
        //        Для создания профиля текущего пользователя
        if self.user == nil {
            block.startAnimating()
            self.apiManger.currentUser(token: APIListManager.token) { [weak self] (result) in
                guard let self = self else { return }
                self.block.stopAnimating()
                
                switch result {
                case .success(let user):
                    self.user = user
                    self.navigationItem.title = user.username
                    self.createPostsArray()
                    self.addLogoutButton()
                    
                    if self.fetchCurrentUser().isEmpty {
                        self.saveCurrentUserInCoreData(user: user)
                    }
                    
                case .failure(let error):
                    switch error {
                    case .offlineMode:
                        guard let user = self.fetchCurrentUser().first else { return }
                        self.user = user
                        self.createPostsArray()
                        self.addLogoutButton()
                        
                    default: return
                    }
                    self.alert.createAlert(error: error)
                }
            }
            
            //        Для создания профилей других пользователей
        } else {
            navigationItem.title = self.user?.username
            createPostsArray()
            self.addLogoutButton()
        }
    }
    
//    Проверка отображать ли кнопку Log out
    private func addLogoutButton() {
        if user?.username == "ivan1975" {
            navigationItem.setRightBarButton(UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logoutPressed)), animated: true)
        }
    }
    
    //    Логика по созданию массива постов
    private func createPostsArray() {
        
        block.startAnimating()
        guard self.user != nil else { return }
        apiManger.userPosts(token: APIListManager.token, id: user!.id) { [weak self] (result) in
            guard let self = self else { return }
            self.block.stopAnimating()
            
            switch result {
            case .success(let post):
                self.postsOfCurrentUser = post
                self.collectionView.reloadData()
                if self.fetchFeedFromCoreData().isEmpty {
                    self.saveFeedInCoreData(posts: post)
                }
                
            case .failure(let error):
                switch error {
                case .offlineMode:
                    guard let user = self.user else { return }
                    self.postsOfCurrentUser = self.fetchFeedFromCoreData().filter({ $0.authorUsername == user.username })
                    
                    self.collectionView.reloadData()
                    
                default: return
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
    
    private func saveCurrentUserInCoreData(user: User) {
        dataManager.saveCurrentUserInCoreData(for: CurrentUser.self, user: user)
    }
    
    private func fetchCurrentUser() -> [User] {
        return dataManager.fetchCurrentUser(for: CurrentUser.self)
    }
    
//    Выход из профиля
    @objc private func logoutPressed() {
        apiManger.signout(token: APIListManager.token) { [weak self] _ in
            guard let self = self else { return }

            APIListManager.token = ""
            self.keychain.deleteToken(userName: "user")
            
                self.appDelegate.window?.rootViewController = AutorizationViewController()
        }
    }
    
    //    Target для перехода на страницу подписчиков
    private func presentFollowers(button: UIButton) {
        button.addTarget(self, action: #selector(presentVCFollowers), for: .touchUpInside)
    }
    
    //    Переход на страницу подписчиков
    @objc private func presentVCFollowers() {
        
        block.startAnimating()
        guard let user = user else { return }
        apiManger.usersFollowing(token: APIListManager.token, id: user.id) { [weak self] (result) in
            guard let self = self else { return }
            self.block.stopAnimating()
            
            switch result {
            case .success(let users):
                let vc = FollowersTableViewController(usersArray: users, titleName: "Followers")
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                self.alert.createAlert(error: error)
            }
        }
    }
    
    //    Target для перехода на страницу подписок
    private func presentFollowing(button: UIButton) {
        button.addTarget(self, action: #selector(presentVCFollowing), for: .touchUpInside)
    }
    
    //    Переход на страницу подписок
    @objc private func presentVCFollowing() {
        block.startAnimating()
        guard let user = user else { return }
        apiManger.usersFollowers(token: APIListManager.token, id: user.id) { [weak self] (result) in
            guard let self = self else { return }
            self.block.stopAnimating()
            
            switch result {
            case .success(let users):
                let vc = FollowersTableViewController(usersArray: users, titleName: "Followers")
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                self.alert.createAlert(error: error)
            }
        }
    }
}

//    MARK:- DataSource and Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let postArray = postsOfCurrentUser else { return 0 }
        return postArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        guard let posts = postsOfCurrentUser else { return UICollectionViewCell() }
        
        let post = posts[indexPath.item]
        cell.setupCell(post: post)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: view.frame.width, height: 86)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifierHeader, for: indexPath) as! ProfileHeaderCell
        guard let user = user else { return header }
        header.user = user
        header.createCell()
        header.delegate = self
        presentFollowers(button: header.followersButton)
        presentFollowing(button: header.followingButton)
        
        return header
    }
}

//    MARK:- FollowUnfollowDelegate
extension ProfileViewController: FollowUnfollowDelegate {
    
    //    Подписаться/отписаться на/от пользователя
    func tapFollowUnfollowButton(user: User) {
        
        if user.currentUserFollowsThisUser {
            apiManger.unfollow(token: APIListManager.token, id: user.id) { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(let user):
                    self.user = user
                    self.collectionView.reloadData()
                    
                case .failure(let error):
                    self.alert.createAlert(error: error)
                }
            }
            
        } else {
            apiManger.follow(token: APIListManager.token, id: user.id) { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(let user):
                    self.user = user
                    self.collectionView.reloadData()
                    
                case .failure(let error):
                    self.alert.createAlert(error: error)
                }
            }
        }
    }
}
