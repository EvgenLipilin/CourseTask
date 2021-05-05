//
//  NewViewController.swift
//  Course2FinalTask
//
//  Created by Евгений on 12.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class NewPostViewController: UIViewController {
    
    private lazy var alert = AlertViewController(view: self)
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let arrayOfNewBigPhotos = ["new1", "new2", "new3", "new4", "new5", "new6", "new7", "new8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(NewPostCell.self, forCellWithReuseIdentifier: identifierNewPost)
        collectionView.dataSource = self
        collectionView.delegate = self
        title = "New"
    }
}


extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayOfNewBigPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierNewPost, for: indexPath) as? NewPostCell else { alert.createAlert(error: nil)
            return UICollectionViewCell() }
        
        let imageItem = UIImage(named: arrayOfNewBigPhotos[indexPath.item])
        guard let image = imageItem else { return UICollectionViewCell() }
        cell.createCell(image: image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AddFilterViewController(bigImage: UIImage(named: arrayOfNewBigPhotos[indexPath.item])!)
        navigationController?.pushViewController(vc, animated: true)
    }
}

