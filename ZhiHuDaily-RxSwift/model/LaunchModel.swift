//
//  LaunchModel.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 11/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//  

import Foundation

struct LaunchModel: Codable {
    var creatives: [LaunchModelImg]?
}

struct LaunchModelImg: Codable {
    var url: String?
    var text: String?
    var start_time : Int?
    var impression_tracks: [String]?
}
