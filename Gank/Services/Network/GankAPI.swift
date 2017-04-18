//
//  NetworkService.swift
//  Gank
//
//  Created by Maru on 2016/12/5.
//  Copyright © 2016年 Maru. All rights reserved.
//

import Foundation
import Moya

enum GankAPI {
    
    enum GankCategory: String {
        
        case All      = "all"
        
        static func mapCategory(with hashValue: Int) -> GankCategory {
            switch hashValue {
            case 0:
                return .All
            default:
                return .All
            }
        }
    }
    
    case data(type: GankCategory,size: Int64,index: Int64)
}

extension GankAPI: TargetType {
    
    
    var baseURL: URL { return URL(string: "http://gank.io")! }
    
    var path: String {
        switch self {
        case .data(let type,let size,let index):
            return "/api/data/\(type.rawValue)/\(size)/\(index)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return "this is a sample data".utf8EncodedData
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    
    var task: Task {
        switch self {
        case .data(_,_,_):
            return .request
        }
    }
}

let gankApi = RxMoyaProvider<GankAPI>()

// MARK: - Helpers

private extension String {
    
    var utf8EncodedData: Data {
        return self.data(using: .utf8)!
    }
}


