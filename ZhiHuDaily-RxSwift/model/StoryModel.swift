//
//  StoryModel.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 11/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//  故事数据模型

import Foundation

struct listModel: Codable {
    var date: String?
    var stories: [storyModel]
    var top_stories: [storyModel]?
}

struct storyModel: Codable {
    var ga_prefix: String?
    var id: Int?
    var images: [String]? //list_stories
    var title: String?
    var type: Int?
    var image: String? //top_stories
    var multipic: Bool?
}
