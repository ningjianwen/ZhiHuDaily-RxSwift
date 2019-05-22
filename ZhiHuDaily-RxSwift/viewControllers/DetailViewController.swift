//
//  DetailViewController.swift
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

class DetailViewController: UIViewController {

    var webview: DetailWebView!
    var previousWeb: DetailWebView!
    var idArr = [Int]()
    var previousId = 0
    var nextId = -1
    var statusBackView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 20)
        $0.isHidden = true
    }
    var statusLight = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    let provider = MoyaProvider<ApiManager>()
    let disposeBag = DisposeBag()
    var id = Int() {
        didSet {
            loadData()
            for (index, element) in idArr.enumerated() {
                if id == element {
                    if index == 0 {
                        //最新一条
                        previousId = 0
                        nextId = idArr[index + 1]
                    }
                    else if (index == idArr.count - 1) {
                        //最后一条
                        nextId = -1
                        previousId = idArr[index - 1]
                    }
                    else {
                        previousId = idArr[index - 1]
                        nextId = idArr[index + 1]
                    }
                    break;
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: UILabel())
        self.webview = DetailWebView.init(frame: view.bounds)
        webview.delegate = self
        self.webview.scrollView.delegate = self
        self.view.addSubview(webview)
        self.previousWeb = DetailWebView.init(frame: CGRect.init(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight))
        self.view.addSubview(previousWeb)
        self.view.addSubview(statusBackView)
        self.setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollViewDidScroll(webview.scrollView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusLight ? .lightContent : .default
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

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        webview.img.frame.origin.y = CGFloat.init(scrollView.contentOffset.y)
        webview.img.frame.size.height = 200 - CGFloat.init(scrollView.contentOffset.y)
        webview.maskImg.frame = CGRect.init(x: 0, y: webview.img.frame.size.height - 100, width: screenWidth, height: 100)
        if scrollView.contentOffset.y > 180 {
            view.bringSubviewToFront(statusBackView)
            statusBackView.isHidden = false
            statusLight = false
        } else {
            statusBackView.isHidden = true
            statusLight = true
        }
        if webview.img.isHidden {
            statusLight = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -60 {
            if previousId > 0 {
                previousWeb.frame = CGRect.init(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight)
                UIView.animate(withDuration: 0.3, animations: {
                    self.webview.transform = CGAffineTransform.init(translationX: 0, y: screenHeight)
                    self.previousWeb.transform = CGAffineTransform.init(translationX: 0, y: screenHeight)
                }, completion: { (state) in
                    if state { self.changeWebview(self.previousId) }
                })
            }
        }
        if scrollView.contentOffset.y - 50 + screenHeight >= scrollView.contentSize.height {
            if nextId > 0 {
                previousWeb.frame = CGRect.init(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
                UIView.animate(withDuration: 0.3, animations: {
                    self.previousWeb.transform = CGAffineTransform.init(translationX: 0, y: -screenHeight)
                    self.webview.transform = CGAffineTransform.init(translationX: 0, y: -screenHeight)
                }, completion: { (state) in
                    if state { self.changeWebview(self.nextId) }
                })
            }
        }
    }
}

extension DetailViewController {
    
    func changeWebview(_ showID: Int) {
        webview.removeFromSuperview()
        previousWeb.scrollView.delegate = self
        previousWeb.delegate = self
        webview = previousWeb
        id = showID
        setUI()
        previousWeb = DetailWebView.init(frame: CGRect.init(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight))
        view.addSubview(previousWeb)
        scrollViewDidScroll(webview.scrollView)
    }
    
    func loadData() {
        provider.rx
            .request(.getNewsDesc(id))
            .mapModel(NewsDetailModel.self)
            .subscribe(onSuccess: { (model) in
                if let imageUrl = model.image{
                    self.webview.img.kf.setImage(with: URL(string: imageUrl))
                    self.webview.titleLab.text = model.title
                } else {
                    self.webview.img.isHidden = true
                    self.webview.previousLab.textColor = UIColor.colorFromHex(0x777777)
                }
                if let image_source = model.image_source {
                    self.webview.imgLab.text = "图片: " + image_source
                }
                if (model.title?.count)! > 16 {
                    self.webview.titleLab.frame = CGRect.init(x: 15, y: 120, width: screenWidth - 30, height: 55)
                }
                OperationQueue.main.addOperation {
                    self.webview.loadHTMLString(self.concatHTML(css: model.css!, body: model.body!), baseURL: nil)
                }
            }, onError: { (_) in
                
            })
            .disposed(by: disposeBag)
    }
    
    private func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\($0)>" }
        html += "<style>img{max-width:320px !important;}</style>"
        html += "</head>"
        html += "<body>"
        html += body
        html += "</body>"
        html += "</html>"
        return html
    }
    
    func setUI() {
        if previousId == 0 {
            webview.previousLab.text = "已经是第一篇了"
        } else {
            webview.previousLab.text = "载入上一篇"
        }
        if nextId == -1 {
            webview.nextLab.text = "已经是最后一篇了"
        } else {
            webview.nextLab.text = "载入下一篇"
        }
    }
    
}

extension DetailViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
//         waitView.isHidden = false
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webview.waitView.removeFromSuperview()
        webview.nextLab.frame = CGRect.init(x: 15, y: self.webview.scrollView.contentSize.height + 10, width: screenWidth - 30, height: 20)
    }
}
