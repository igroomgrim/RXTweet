//
//  GithubApi.swift
//  RXTweet
//
//  Created by Anak Mirasing on 4/25/16.
//  Copyright © 2016 VINTX. All rights reserved.
//

import Foundation
import Moya

enum ApiService {
    case GetUsers
    case GetUsersWithRandomOffset
}

private func JSONResponseDataFormatter(data: NSData) -> NSData {
    do {
        let dataAsJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let prettyData =  try NSJSONSerialization.dataWithJSONObject(dataAsJSON, options: .PrettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}

let GitProvider = RxMoyaProvider<ApiService>(plugins: [NetworkLoggerPlugin(verbose: false, responseDataFormatter: JSONResponseDataFormatter)])

extension ApiService: TargetType {
    
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
    
    var path: String {
        
        switch self {
        case .GetUsers, .GetUsersWithRandomOffset:
            return "/users"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .GetUsers, .GetUsersWithRandomOffset:
            return .GET
        }
    }
    
    var parameters: [String: AnyObject]? {
        
        switch self {
        case .GetUsers:
            return nil
        case .GetUsersWithRandomOffset:
            let randomOffset = Int(arc4random_uniform(UInt32(100)))
            return ["since": randomOffset]
        }
    }
    
    var sampleData: NSData {
        switch self {
        case .GetUsers, .GetUsersWithRandomOffset:
            return "[]".dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
}