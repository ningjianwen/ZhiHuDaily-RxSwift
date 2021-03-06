//
//  ListTableViewCell.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit

let imgWidth: CGFloat = 75

class ListTableViewCell: UITableViewCell {
    lazy var title: UILabel = {
       var label = UILabel()
       label.font = UIFont.systemFont(ofSize: 15)
       label.lineBreakMode = NSLineBreakMode.byTruncatingTail
       return label
    }()
    
    lazy var img: UIImageView = {
       var img = UIImageView()
        
       return img
    }()
    lazy var morePicImg: UIImageView = {
        var morePic = UIImageView()
        morePic.image = UIImage(named: "Home_Morepic")
        return morePic
    }()
    
//    var titleRight: CGFloat!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(){
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.img)
        self.img.addSubview(self.morePicImg)
        
        let titleRight = screenWidth - imgWidth - 20.0
        self.title.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.height.equalTo(18)
            make.right.equalTo(titleRight)
        }
        
        self.img.snp.makeConstraints { (make) in
            make.width.equalTo(imgWidth)
            make.height.equalTo(60)
            make.top.equalTo(self.title.snp.top)
            make.right.equalTo(10)
        }
        
        self.morePicImg.snp.makeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(14)
            make.bottom.right.equalToSuperview()
        }
    }
    
    var cellModel: storyModel! {
        didSet{
            self.title.text = cellModel.title
            self.img.kf.setImage(with: URL(string: (cellModel.images?.first)!))
            self.morePicImg.isHidden = !(cellModel.multipic ?? false)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
