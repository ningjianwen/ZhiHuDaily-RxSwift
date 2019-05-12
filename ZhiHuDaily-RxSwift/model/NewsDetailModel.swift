//
//  NewsDetailModel.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 11/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//  新闻详情

import Foundation

struct NewsDetailModel: Codable {
    var body: String?
    var ga_prefix: String?
    var id: Int?
    var image: String?
    var image_source: String?
    var share_url: String?
    var title: String?
    var type: Int?
    var images: [String]?
    var css: [String]?
    var js: [String]?
}

