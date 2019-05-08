//
//  LoadingCell.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class LoadingCell: TableBaseCell {
    
    let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        indicator.style = .white
        indicator.color = UIColor.red
        return indicator
    }()

    override func prepareForReuse() {
        if indicator.isAnimating {
            indicator.stopAnimating()
        }
    }
    
    override func setupCell() {
        self.addSubview(indicator)
        indicator.snp.makeConstraints { (m) in
            m.centerY.centerX.equalTo(self)
        }
    }
}
