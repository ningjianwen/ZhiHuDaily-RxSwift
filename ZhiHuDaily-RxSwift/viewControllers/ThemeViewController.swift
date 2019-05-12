//
//  ThemeViewController.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher
import RxCocoa
import RxDataSources
import Moya

let tableViewCellIdentifer = "ListTableViewCell"

class ThemeViewController: UIViewController {

    lazy var tableView: UITableView = {
        var table = UITableView.init(frame: self.view.frame, style: .plain)
        return table
    }()
    lazy var avatar: UIImageView = UIImageView()
    var avatarHeight: CGFloat!
    lazy var titleLab: UILabel = {
        var label = UILabel()
        
        return label
    }()
    lazy var menuButton: UIButton = {
        var btn = Button.init(type: .custom)
        return btn
    }()
    
    let disposeBag = DisposeBag()
    let menuView = MenuViewController.sharedInstance
    let provider = MoyaProvider<ApiManager>()
    let listModelArr = Variable([storyModel]())
    var id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.loadData()
        self.menuButton.rx.tap.subscribe(onNext: { (_) in
            self.menuView.showView = !self.menuView.showView
        })
        .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name(rawValue: "setTheme"))
            .subscribe(onNext: { (notif) in
                let model = notif.userInfo?["model"] as! ThemeModel
                self.titleLab.text = model.name
                self.avatar.kf.setImage(with: URL(string: model.thumbnail!))
                self.id = model.id!
                self.loadData()
            })
            .disposed(by: disposeBag)
        
        //设置代理要放在绑定数据之前，否者无效！！！
        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        listModelArr
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: tableViewCellIdentifer, cellType: ListTableViewCell.self)) {
                (row, model, cell) in
                cell.title.text = model.title
                cell.morePicImg.isHidden = !(model.multipic ?? false)
                if model.images != nil {
                    cell.img.isHidden = false
                    cell.titleRight = 105
                    cell.img.kf.setImage(with: URL(string: (model.images?.first)!))
                } else {
                    cell.img.isHidden = true
                    cell.titleRight = 15
                }
            }
            .disposed(by: disposeBag)
        
        self.tableView.rx
            .modelSelected(storyModel.self)
            .subscribe(onNext: { (model) in
                self.menuView.showView = false
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                let detailVc = DetailViewController()
                self.listModelArr.value.forEach({ (model) in
                    detailVc.idArr.append(model.id!)
                })
                detailVc.id = model.id!
                self.navigationController?.pushViewController(detailVc, animated: true)
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ThemeViewController{
    
    func setupUI(){
        let avatarH = UIApplication.shared.statusBarFrame.height + 44
        titleLab.text = UserDefaults.standard.object(forKey: "themeName") as! String?
        id = UserDefaults.standard.object(forKey: "themeNameId") as! Int
        avatar.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "themeImgUrl") as! String))
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(pan:))))
    }
    @objc func panGesture(pan: UIPanGestureRecognizer) {
        menuView.panGesture(pan: pan)
    }
    func loadData(){
        provider.rx
            .request(.getThemeDesc(id))
            .mapModel(listModel.self)
            .subscribe(onSuccess: { (model) in
                self.listModelArr.value = model.stories
                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
                self.navigationController?.navigationBar.subviews.first?.alpha = 0
            })
            .disposed(by: disposeBag)
    }
}

extension ThemeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

