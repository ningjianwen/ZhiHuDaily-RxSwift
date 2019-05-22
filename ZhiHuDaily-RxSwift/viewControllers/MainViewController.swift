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
            self.launchView.kf.setImage(with: URL(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1558027909911&di=912027103492e5454606ab00601a08ee&imgtype=0&src=http%3A%2F%2Fimg1.ph.126.net%2FPsoIfC3TYdHx9t_gki2CwA%3D%3D%2F3859021930803194683.jpg"), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { result in
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
//            if let imgModel = model.creatives?.first{
//                self.launchView.kf.setImage(with: URL(string: imgModel.url!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { result in
//                    UIView.animate(withDuration: 1.5, animations: {
//                        self.launchView.alpha = 1
//                    }){(_) in
//                        UIView.animate(withDuration: 0.3, animations: {
//                            self.launchView.alpha = 0
//                        }, completion: { (_) in
//
//                            self.launchView.removeFromSuperview()
//                        })
//                    }
//                    })
//                }else{
//                    self.launchView.removeFromSuperview()
//                }
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
