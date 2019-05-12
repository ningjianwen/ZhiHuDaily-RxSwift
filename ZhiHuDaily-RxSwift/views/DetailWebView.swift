//
//  DetailWebView.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit
import WebKit

class DetailWebView: WKWebView {
    var img = UIImageView().then {
        $0.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    var maskImg = UIImageView().then {
        $0.frame = CGRect.init(x: 0, y: 100, width: screenWidth, height: 100)
        $0.image = UIImage.init(named: "Home_Image_Mask")
    }
    var titleLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: 150, width: screenWidth - 30, height: 26)
        $0.font = UIFont.boldSystemFont(ofSize: 21)
        $0.numberOfLines = 2
        $0.textColor = UIColor.white
    }
    var imgLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: 180, width: screenWidth - 30, height: 16)
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textAlignment = .right
        $0.textColor = UIColor.white
    }
    var previousLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: -38, width: screenWidth - 30, height: 20)
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.text = "载入上一篇"
        $0.textAlignment = .center
        $0.textColor = UIColor.white
    }
    var nextLab = UILabel().then {
        $0.frame = CGRect.init(x: 15, y: screenHeight + 30, width: screenWidth - 30, height: 20)
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.text = "载入下一篇"
        $0.textAlignment = .center
        $0.textColor = UIColor.colorFromHex(0x777777)
    }
    var waitView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        let acv = UIActivityIndicatorView(style: .gray)
        acv.center = $0.center
        acv.startAnimating()
        $0.addSubview(acv)
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.img.addSubview(self.maskImg)
        self.scrollView.addSubview(self.img)
        self.scrollView.addSubview(self.titleLab)
        self.scrollView.addSubview(self.imgLab)
        self.scrollView.addSubview(self.previousLab)
        self.scrollView.addSubview(self.nextLab)
        self.scrollView.addSubview(self.waitView)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
