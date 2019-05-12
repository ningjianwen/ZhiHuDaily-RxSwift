//
//  ThemeModel.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 11/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//  主题

import Foundation

struct ThemeResponseModel: Codable {
    var others: [ThemeModel]?
}

struct ThemeModel: Codable {
    var thumbnail: String?
    var id: Int?
    var description: String?
    var name: String?
}
