//
//  ToModelExtension.swift
//  ZhiHuDaily-RxSwift
//
//  Created by jianwen ning on 11/05/2019.
//  Copyright © 2019 jianwen ning. All rights reserved.
//  JSON -> Model

import Foundation
import Moya
import RxSwift

extension Response{
    //json转model
    func mapModel<T: Codable>(_ type: T.Type) throws -> T{
        print(String.init(data: data, encoding: .utf8) ?? "")
        do {
           return try JSONDecoder().decode(type, from: data)
        } catch {
            throw MoyaError.jsonMapping(self)
        }
    }
}

extension PrimitiveSequence where TraitType == SingleTrait,ElementType == Response{
    func mapModel<T: Codable>(_ type: T.Type) ->Single<T>{
        return flatMap{response -> Single<T> in
            return Single.just(try response.mapModel(T.self))
        }
    }
}
