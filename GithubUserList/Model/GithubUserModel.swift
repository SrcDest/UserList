//
//  GIthubUserModel.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import ObjectMapper

class GithubUserModel: Mappable {
    public var login: String?
    public var avatar_url: String?
    public var score: Float?
    
    public init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        login <- map["login"]
        avatar_url <- map["avatar_url"]
        score <- map["score"]
    }
}
