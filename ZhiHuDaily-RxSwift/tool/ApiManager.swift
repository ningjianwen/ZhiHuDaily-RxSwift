//
//  ApiManager.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 11/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//  network request url manager

import Foundation
import Moya

enum ApiManager {
    case getLaunchImg
    case getNewsList
    case getMoreNews(String)
    case getThemeList
    case getThemeDesc(Int)
    case getNewsDesc(Int)
}

extension ApiManager: TargetType{
    
    var baseURL: URL{
        return URL(string: "http://news-at.zhihu.com/api/")!
    }
    var task: Task{
        return .requestPlain
    }
    var headers: [String : String]?{
        return ["Content-type": "application/json"]
    }
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String{
        switch self{
        case .getLaunchImg:
            return "7/prefetch-launch-images/750*1142"
        case .getNewsList:
            return "4/news/latest"
        case .getMoreNews(let date):
            return "4/news/before/" + date
        case .getThemeList:
            return "4/themes"
        case .getThemeDesc(let id):
            return "4/theme/\(id)"
        case .getNewsDesc(let id):
            return "4/news/\(id)"
        }
    }
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .get
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
}
