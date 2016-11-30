//
//  RequestInfo.swift
//  ProtobufClient
//
//  Created by Kyohei Ito on 2016/11/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

struct RequestInfo {
    enum ContentType: CustomStringConvertible {
        case json, protobuf
        var description: String {
            switch self {
            case .json:         return "application/json"
            case .protobuf:     return "application/protobuf"
            }
        }
    }
    
    enum API: CustomStringConvertible {
        case swift, go
        var description: String {
            switch self {
            case .swift:    return "api type is swift"
            case .go:       return "api type is go"
            }
        }
        var port: String {
            switch self {
            case .swift:    return ":8090"
            case .go:      return ":8080"
            }
        }
    }
    
    let api: API
    let type: ContentType
    let path: String
    var url: String {
        return "http://localhost\(api.port)\(path)"
    }
}
