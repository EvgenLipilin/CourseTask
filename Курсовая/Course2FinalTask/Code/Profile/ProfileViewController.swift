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
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCurrentUserAndPosts()
        
        collectionView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCell")
        collectionView.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifierHeader)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    //    Обновляет массив постов при публикации нового поста
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        createPostsArray()
    }
    
    // Создает текущего пользователя и массив его постов
    private func createCurrentUserAndPosts() {
        
        //Создает профиль текущего пользователя
        if self.user == nil {
            block.startAnimating()
            self.apiManger.currentUser(token: APIListManager.token) { [weak self] (result) in
                guard let self = self else { return }
                self.block.stopAnimating()
                
                switch result {
                case .successfully(let user):
                    self.user = user
                    self.navigationItem.title = user.username
                    self.createPostsArray()
                    self.addLogoutButton()
                    
                case .failed(let error):
                    self.alert.createAlert(error: error)
                }
            }
            
            //        Для создания профилей других пользователей
        } else {
            DispatchQueue.main.async {
                self.navigationItem.title = self.user?.username
            }
            createPostsArray()
        }
    }
    
    //    Проверка отображать ли кнопку Log out
        private func addLogoutButton() {
            if user?.username == "ivan1975" {
                navigationItem.setRightBarButton(UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logoutPressed)), animated: true)
            }
        }
    
    //    Выход из профиля
        @objc private func logoutPressed() {
            apiManger.signout(token: APIListManager.token) { [weak self] _ in
                guard let self = self else { return }

                APIListManager.token = ""
                    self.appDelegate.window?.rootViewController = AutorizationViewController()
            }
        }

    
    //Создание массива постов
    private func createPostsArray() {
        
        block.startAnimating()
        guard self.user != nil else { return }
        self.postClass.findPosts(by: self.user!.id, queue: .global()) { [weak self] (postsArray) in
            guard let self = self else { return }
            guard postsArray != nil else { return }
            self.postsOfCurrentUser = postsArray
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.block.stopAnimating()
            }
        }
    }
    
    //Переход на страницу подписчиков
    private func presentFollowers(button: UIButton) {
        button.addTarget(self, action: #selector(presentVCFollowers), for: .touchUpInside)
    }
    
    //Переход на страницу подписчиков*
    @objc private func presentVCFollowers() {
        
        block.startAnimating()
        guard let user = user else { return }
        apiManger.usersFollowing(token: APIListManager.token, id: user.id) { [weak self] (result) in
            guard let self = self else { return }
            self.block.stopAnimating()
            
            switch result {
            case .successfully(let users):
                let vc = FollowersTableViewController(usersArray: users, titleName: "Followers")
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failed(let error):
                self.alert.createAlert(error: error)
            }
        }
    }
    
    //Переход на страницу подписок
    private func presentFollowing(button: UIButton) {
        button.addTarget(self, action: #selector(presentVCFollowing), for: .touchUpInside)
    }
    
    //Переход на страницу подписок*
    @objc private func presentVCFollowing() {
        block.startAnimating()
        guard let user = user else { return }
        userClass.usersFollowedByUser(with: user.id, queue: DispatchQueue.global()) { [weak self] (usersArray) in
            guard let self = self else { return }
            guard usersArray != nil else { self.alert.createAlert {_ in
                self.usersFollowedByUser = []
                }
                return }
            self.usersFollowedByUser = usersArray
            if let array = self.usersFollowedByUser {
                DispatchQueue.main.async {
                    self.block.stopAnimating()
                    self.navigationController?.pushViewController(FollowersTableViewController(usersArray: array, titleName: "Following", user: user), animated: true)
                }
            }
        }
    }
}


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
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifierHeader, for: indexPath) as? ProfileHeaderCell else { return UICollectionReusableView() }
            guard let user = user else { return header }
            header.currentUser = currentUser
            header.user = user
            header.createCell()
            header.delegate = self
            presentFollowers(button: header.followersButton)
            presentFollowing(button: header.followingButton)
            
            return header
        }
    }

extension ProfileViewController: FollowUnfollowDelegate {
    
    //Подписаться-подписаться на-от пользователя
    func tapFollowUnfollowButton(user: User) {
        
        if user.currentUserFollowsThisUser {
            userClass.unfollow(user.id, queue: .global()) { (_) in
                self.userClass.user(with: user.id, queue: .global()) { [weak self] (user) in
                    guard let self = self else { return }
                    guard let user = user else { self.alert.createAlert {_ in}
                        return }
                    self.user = user
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
            
        } else {
            userClass.follow(user.id, queue: .global()) { (_) in
                self.userClass.user(with: user.id, queue: .global()) { [weak self] (user) in
                    guard let self = self else { return }
                    guard let user = user else { self.alert.createAlert {_ in}
                        return }
                    self.user = user
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}
