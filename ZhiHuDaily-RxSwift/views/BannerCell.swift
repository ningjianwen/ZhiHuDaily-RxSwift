//
//  BannerCell.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 11/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit
import SnapKit

class BannerCell: UICollectionViewCell {
    lazy var img: UIImageView = UIImageView()
    lazy var imgMask: UIImageView = UIImageView()
    lazy var imgTitle: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    func initUI(){
        self.contentView.addSubview(self.img)
        self.contentView.addSubview(self.imgMask)
        self.contentView.addSubview(self.imgTitle)
        
        self.img.snp.makeConstraints { (make) in
            make.height.width.equalTo(self.contentView)
            make.top.left.equalTo(self.contentView)
        }
        self.imgMask.image = UIImage(named: "Home_Image_Mask")
        self.imgMask.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(self.img.snp.height).dividedBy(2)
        }
        self.imgTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(55)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
