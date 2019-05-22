//
//  MenuViewController.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//  侧边栏菜单

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Moya
import SwiftDate

let menuWidth:CGFloat = 225 // 菜单的宽度
let themeCellIdentifier = "themeTableViewCell"

class MenuViewController: UIViewController {

    lazy var tableView: UITableView = {
        var table = UITableView.init(frame: self.view.frame, style: .plain)
        return table
    }()
    let provider = MoyaProvider<ApiManager>()
    let disposeBag = DisposeBag()
    let themeArr = Variable([ThemeModel]())
    var bindtoNav: UITabBarController?
    var beganDate: Date?
    var endDate: Date?
    var showView = false {
        didSet{
            showView ? showMenu() : dismissMenu()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.addSubview(self.tableView)
        provider.rx
            .request(.getThemeList)
            .mapModel(ThemeResponseModel.self)
            .subscribe(onSuccess: { (model) in
                self.themeArr.value = model.others!
                var model = ThemeModel()
                model.name = "首页"
                self.themeArr.value.insert(model, at: 0) //把数据查到首位
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top) //选中第0行
            })
            .disposed(by: disposeBag)
        
        themeArr
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: themeCellIdentifier, cellType: ThemeTableViewCell.self)){
             (row, model, cell) in
                cell.nameLab.text = model.name
                cell.homeIcon.isHidden = row == 0 ? false : true
                cell.nameLeft = row == 0 ? 50 : 15
        }
        .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(ThemeModel.self)
            .subscribe(onNext: { (model) in
                self.showView = false
                self.showThemeVC(model)
            })
            .disposed(by: disposeBag)
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

extension MenuViewController{
    
    static let sharedInstance = createMenuView()
    private static func createMenuView() -> MenuViewController{
        let menuVC = MenuViewController()
        menuVC.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: screenHeight)
        return menuVC
    }
    
    func showThemeVC(_ model: ThemeModel){
        if model.id == nil{
            bindtoNav?.selectedIndex = 0
        }else{
            bindtoNav?.selectedIndex = 1
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setTheme"), object: nil, userInfo: ["model": model])
            UserDefaults.standard.set(model.name, forKey: "themeName")
            UserDefaults.standard.set(model.thumbnail, forKey: "themeImgUrl")
            UserDefaults.standard.set(model.id!, forKey: "themeNameId")
        }
    }
    func swipeGesture(swipe: UISwipeGestureRecognizer) {
        if swipe.state == .ended {
            if swipe.direction == .left && showView {
                showView = false
            }
            if swipe.direction == .right && !showView {
                showView = true
            }
        }
    }
    
    func panGesture(pan: UIPanGestureRecognizer) {
        let xoff = pan.translation(in: view).x
        if pan.state == .began {
            beganDate = Date()
        }
        if pan.state == .ended {
            endDate = Date()
            //区分是轻扫还是滑动
            if endDate! < beganDate! + 150000000.nanoseconds {
                if xoff > 0 {
                    showView = true
                } else {
                    showView = false
                }
                return
            }
        }
        if (0 < xoff && xoff <= menuWidth && !showView) || (0 > xoff && xoff >= -menuWidth && showView) {
            if pan.translation(in: view).x > 0 {
                moveMenu(pan.translation(in: view).x)
            } else {
                moveMenu(menuWidth + pan.translation(in: view).x)
            }
            if pan.state == .ended {
                if showView {
                    if pan.translation(in: view).x < -175 {
                        showView = false
                    } else {
                        showView = true
                    }
                } else {
                    if pan.translation(in: view).x > 50 {
                        showView = true
                    } else {
                        showView = false
                    }
                }
            }
        }
    }
    
    func moveMenu(_ xoff: CGFloat) {
        let view = UIApplication.shared.keyWindow?.subviews.first
        let menuView = UIApplication.shared.keyWindow?.subviews.last
        UIApplication.shared.keyWindow?.bringSubviewToFront((UIApplication.shared.keyWindow?.subviews[1])!)
        view?.transform = CGAffineTransform.init(translationX: xoff, y: 0)
        menuView?.transform = (view?.transform)!
    }
    
    func showMenu() {
        let view = UIApplication.shared.keyWindow?.subviews.first
        let menuView = UIApplication.shared.keyWindow?.subviews.last
        UIApplication.shared.keyWindow?.bringSubviewToFront((UIApplication.shared.keyWindow?.subviews[1])!)
        UIView.animate(withDuration: 0.3, animations: {
            view?.transform = CGAffineTransform.init(translationX: 225, y: 0)
            menuView?.transform = (view?.transform)!
        })
    }
    
    func dismissMenu() {
        let view = UIApplication.shared.keyWindow?.subviews.first
        let menuView = UIApplication.shared.keyWindow?.subviews.last
        UIApplication.shared.keyWindow?.bringSubviewToFront((UIApplication.shared.keyWindow?.subviews[1])!)
        UIView.animate(withDuration: 0.5, animations: {
            view?.transform = CGAffineTransform.init(translationX: 0, y: 0)
            menuView?.transform = (view?.transform)!
        })
    }
    
}
