//
//  HomeViewController.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 12/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import Kingfisher
import RxCocoa
import RxDataSources
import SwiftDate
import Then

let ListTableViewCellIdentifier: String = "ListTableViewCell"

class HomeViewController: UIViewController {

    let provider = MoyaProvider<ApiManager>()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,storyModel>>(configureCell: { (dataSource, tableview, indexPath, model) -> UITableViewCell in
        let cell = tableview.dequeueReusableCell(withIdentifier: ListTableViewCellIdentifier) as! ListTableViewCell
        cell.cellModel = model
        return cell
    })
    
    let disposeBag = DisposeBag()
    let dataArr = Variable([SectionModel<String, storyModel>]())
    var newsDate = ""
    let titleNum = Variable(0)
    var refreshView: RefreshView?
//    let menuView = MenuViewController.sharedInstance
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: self.view.frame, style: .plain)
        tableView.rowHeight = 90.0
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCellIdentifier)
        return tableView
    }()
    
    lazy var bannerView: BannerView = {
        var flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: screenWidth, height: 200)
        var banner = BannerView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200), collectionViewLayout: flowLayout)
        return banner
    }()
    lazy var pageControl: UIPageControl = {
        var pageControl = UIPageControl.init(frame: CGRect(x: 0, y: 170, width: screenWidth, height: 20))
        return pageControl
    }()
    lazy var customNav: UIView = {
        var nav = UIView()
        return nav
    }()
    lazy var menuButton: UIButton = {
        var btn = UIButton.init(type: .custom)
        return btn
    }()
    lazy var titleLab: UILabel = {
        var lab = UILabel()
        return lab
    }()
    
    var customNavHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(self.tableView)
        self.tableView.tableHeaderView = self.bannerView
        self.bannerView.addSubview(self.pageControl)
        
        loadData()
//        setBarUI()
        addRefresh()
        
        dataArr.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(storyModel.self)
            .subscribe(onNext: { (model) in
//                self.menuView.showView = false
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                let detailVc = DetailViewController()
                self.dataArr.value.forEach { (sectionModel) in
                    sectionModel.items.forEach({ (storyModel) in
                        detailVc.idArr.append(storyModel.id!)
                    })
                }
                detailVc.id = model.id!
                self.navigationController?.pushViewController(detailVc, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
//        menuButton.rx
//            .tap
//            .subscribe(onNext: { self.menuView.showView = !self.menuView.showView })
//            .disposed(by: disposeBag)
        
        titleNum
            .asObservable()
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (num) in
                if num == 0 {
                    self.titleLab.text = "今日要闻"
                } else {
                    if let date = DateInRegion(self.dataSource[num].model, format: "yyyyMMdd") {
                        self.titleLab.text = "\(date.month)月\(date.day)日 \(date.weekday.toWeekday())"
                    }
                }
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

extension HomeViewController{
    
    func loadData(){
        provider.rx
            .request(.getNewsList)
            .mapModel(listModel.self)
            .subscribe(onSuccess: { (model) in
                self.dataArr.value = [SectionModel(model: model.date!, items: model.stories)]
                self.newsDate = model.date!
                var arr = model.top_stories!
                arr.insert(arr.last!, at: 0)
                arr.append(arr[1])
                self.bannerView.imgUrlArr.value = arr
                self.pageControl.numberOfPages = model.top_stories!.count
                self.refreshView?.endRefresh()
            })
            .disposed(by: disposeBag)
    }
    func loadMoreData() {
        provider.rx
            .request(.getMoreNews(newsDate))
            .mapModel(listModel.self)
            .subscribe(onSuccess: { (model) in
                self.dataArr.value.append(SectionModel(model: model.date!, items: model.stories))
                self.newsDate = model.date!
            })
            .disposed(by: disposeBag)
    }
    func setBarUI() {
        self.customNavHeight = UIApplication.shared.statusBarFrame.size.height + 44
        tableView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
//        if kNavigationBarH > 64 {
//            headView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 200 + kNavigationBarH - 64)
//            tableView.tableHeaderView = headView
//        }
        
        bannerView.bannerDelegate = self
//        UIApplication.shared.keyWindow?.addSubview(menuView.view)
//        menuView.bindtoNav = navigationController?.tabBarController
//        view.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(panGesture(pan:))))
//        menuView.view.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(panGesture(pan:))))
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    @objc func panGesture(pan: UIPanGestureRecognizer) {
//        menuView.panGesture(pan: pan)
    }
    
    func addRefresh() {
        refreshView = RefreshView.init(frame: CGRect.init(x: 118, y: UIApplication.shared.statusBarFrame.size.height + 44 - 50, width: 40, height: 40))
        refreshView?.center.y = UIApplication.shared.statusBarFrame.size.height + 44 - 20.5
        refreshView?.backgroundColor = UIColor.clear
        customNav.addSubview(refreshView!)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == dataArr.value.count - 1 && indexPath.row == 0 {
            loadMoreData()
        }
        self.titleNum.value = (tableView.indexPathsForVisibleRows?.reduce(Int.max) { (result, ind) -> Int in return min(result, ind.section) })!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 {
            return UILabel().then {
                $0.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 38)
                $0.backgroundColor = UIColor.rgb(63, 141, 208)
                $0.textColor = UIColor.white
                $0.font = UIFont.systemFont(ofSize: 15)
                $0.textAlignment = .center
                if let date = DateInRegion(dataSource[section].model, format: "yyyyMMdd") {
                    $0.text = "\(date.month)月\(date.day)日 \(date.weekday.toWeekday())"
                }
            }
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 38
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}

//刷新处理
extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        bannerView.offy.value = Double(scrollView.contentOffset.y)
        customNav.backgroundColor = UIColor.colorFromHex(0x3F8DD0).withAlphaComponent(scrollView.contentOffset.y / 200)
        refreshView?.pullToRefresh(progress: -scrollView.contentOffset.y / 64)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -64 {
            refreshView?.beginRefresh {
                self.loadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshView?.resetLayer()
    }
    
}

//banner 的滑动处理
extension HomeViewController: BannerDelegate {
    
    func selectedItem(model: storyModel) {
//        menuView.showView = false
        let detailVc = DetailViewController()
        self.dataArr.value.forEach { (sectionModel) in
            sectionModel.items.forEach({ (storyModel) in
                detailVc.idArr.append(storyModel.id!)
            })
        }
        detailVc.id = model.id!
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
    
    func scrollTo(index: Int) {
        pageControl.currentPage = index
    }
    
}
