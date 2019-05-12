//
//  ThemeTableViewCell.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    lazy var nameLab: UILabel = UILabel()
    lazy var homeIcon: UIImageView = UIImageView()
    var nameLeft: CGFloat!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.addSubview(self.nameLab)
        self.contentView.addSubview(self.homeIcon)
        
        self.nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLeft)
            make.top.equalTo(16)
            make.width.equalTo(31)
            make.height.equalTo(18)
        }
        
        self.homeIcon.snp.makeConstraints { (make) in
            make.left.equalTo(22)
            make.top.equalTo(15)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.nameLab.font = UIFont.boldSystemFont(ofSize: 15)
            self.nameLab.textColor = UIColor.white
            contentView.backgroundColor = UIColor.colorFromHex(0x1D2328)
            homeIcon.image = UIImage(named: "Menu_Icon_Home_Highlight")
        } else {
            self.nameLab.font = UIFont.systemFont(ofSize: 15)
            self.contentView.backgroundColor = UIColor.clear
            homeIcon.image = UIImage(named: "Menu_Icon_Home")
        }
    }

}
