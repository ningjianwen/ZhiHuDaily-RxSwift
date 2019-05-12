//
//  MainViewController.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit
import Moya
import Kingfisher
import RxSwift

class MainViewController: UITabBarController {

    let provider = MoyaProvider<ApiManager>()
    let launchView = UIImageView()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLaunchView()
        // Do any additional setup after loading the view.
    }
    
    func setLaunchView(){
        self.launchView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.launchView.alpha = 0.99
        self.launchView.backgroundColor = UIColor.purple
        self.view.addSubview(self.launchView)
        
        provider.rx.request(.getLaunchImg).mapModel(LaunchModel.self).subscribe(onSuccess: { (model) in
            if let imgModel = model.creatives?.first{
                self.launchView.kf.setImage(with: URL(string: imgModel.url!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { result in
                    UIView.animate(withDuration: 1.5, animations: {
                        self.launchView.alpha = 1
                    }){(_) in
                        UIView.animate(withDuration: 0.3, animations: {
                            self.launchView.alpha = 0
                        }, completion: { (_) in
                            
                            self.launchView.removeFromSuperview()
                        })
                    }
                    })
                }else{
                    self.launchView.removeFromSuperview()
                }
        }).disposed(by: disposeBag)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
