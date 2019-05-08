//
//  OrgCollectionViewCell.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class OrgCollectionViewCell: UICollectionViewCell {
    let orgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    override func prepareForReuse() {
        orgImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCell()
    }
    
    func setupCell() {
        self.addSubview(orgImageView)
        orgImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(40)
            m.centerX.centerY.equalTo(self)
        }
    }
}
