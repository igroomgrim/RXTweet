//
//  User.swift
//  RXTweet
//
//  Created by Anak Mirasing on 4/25/16.
//  Copyright © 2016 VINTX. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var username: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        username <- map["login"]
    }
    
    
}
