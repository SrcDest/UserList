//
//  UserListTableCell.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import Kingfisher

class UserListTableCell: TableBaseCell {
    
    // MARK:- Properties
    
    fileprivate let orgCell = "orgCell"
    var orgList: [[String : Any]] = []
    
    // MARK: Controls
    
    let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textColor = UIColor.gray
        return label
    }()
    let orgCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK:- Functions
    
    override func prepareForReuse() {
        userProfileImageView.image = nil
        userNameLabel.text = nil
        scoreLabel.text = nil
    }
    
    override func setupCell() {
        self.addSubview(userProfileImageView)
        self.addSubview(userNameLabel)
        self.addSubview(scoreLabel)
        self.addSubview(orgCollectionView)
        
        userProfileImageView.snp.makeConstraints { (m) in
            m.height.width.equalTo(50)
            m.left.top.equalTo(self).offset(12.5)
        }
        userNameLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(userProfileImageView.snp.centerY).offset(-1.5)
            m.left.equalTo(userProfileImageView.snp.right).offset(5)
            m.right.equalTo(self).offset(-12.5)
        }
        scoreLabel.snp.makeConstraints { (m) in
            m.top.equalTo(userProfileImageView.snp.centerY).offset(1.5)
            m.left.right.equalTo(userNameLabel)
        }
        orgCollectionView.snp.makeConstraints { (m) in
            m.top.equalTo(userProfileImageView.snp.bottom).offset(3)
            m.left.equalTo(userProfileImageView)
            m.right.equalTo(userNameLabel)
            m.height.equalTo(40)
        }
        
        orgCollectionView.dataSource = self
        orgCollectionView.register(OrgCollectionViewCell.self, forCellWithReuseIdentifier: orgCell)
        if let flowLayout = orgCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 5
            flowLayout.itemSize = CGSize(width: 40, height: 40)
        }
    }
}

// MARK:- Extension

extension UserListTableCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orgList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: orgCell, for: indexPath) as! OrgCollectionViewCell
        if let urlString = orgList[indexPath.item]["avatar_url"] as? String, let url = URL(string: urlString) {
            cell.orgImageView.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
        }
        
        return cell
    }
}
