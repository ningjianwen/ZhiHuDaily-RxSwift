//
//  BannerView.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa
import Kingfisher

let cellIdentifier = "bannercell"

class BannerView: UICollectionView {

    let imgUrlArr = Variable([storyModel]())
    let disposeBag = DisposeBag()
    var offy = Variable(0.0)
    var bannerDelegate: BannerDelegate?
    
    override func awakeFromNib() {

    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout){
        super.init(frame: frame, collectionViewLayout: layout)
        self.register(BannerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentOffset.x = screenWidth
        imgUrlArr
            .asObservable()
            .bind(to: rx.items(cellIdentifier: cellIdentifier, cellType: BannerCell.self)){
                (row, model, cell) in
                cell.img.kf.setImage(with: URL(string: model.image!))
                cell.imgTitle.text = model.title!
            }
            .disposed(by: disposeBag)
        
        rx.setDelegate(self).disposed(by: disposeBag)
        
        offy
            .asObservable()
            .subscribe(onNext: { (offy) in
                self.visibleCells.forEach({ (cell) in
                    let cell = cell as! BannerCell
                    cell.img.frame.origin.y = CGFloat.init(offy)
                    cell.img.frame.size.height = 200 - CGFloat.init(offy)
                })
            })
            .disposed(by: disposeBag)
        
        rx.modelSelected(storyModel.self).subscribe(onNext: { (model) in
            self.bannerDelegate?.selectedItem(model: model)
        }).disposed(by: disposeBag)
    }
}

extension BannerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == CGFloat.init(imgUrlArr.value.count - 1) * screenWidth {
            scrollView.contentOffset.x = screenWidth
        }
        else if scrollView.contentOffset.x == 0 {
            scrollView.contentOffset.x = CGFloat.init(imgUrlArr.value.count - 2) * screenWidth
        }
        bannerDelegate?.scrollTo(index: Int(scrollView.contentOffset.x / screenWidth) - 1)
    }
}

protocol BannerDelegate {
    func selectedItem(model: storyModel)
    func scrollTo(index: Int)
}
