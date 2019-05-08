//
//  GithubSearchUserModel.swift
//  GithubUserList
//
//  Created by shhan on 08/05/2019.
//  Copyright © 2019 test. All rights reserved.
//

import ObjectMapper

class GithubSearchUserModel: Mappable {
    public var total_count: Int?
    public var incomplete_results: Bool?
    public var items: [GithubUserModel]?
    
    public init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        total_count <- map["total_count"]
        incomplete_results <- map["incomplete_results"]
        items <- map["items"]
    }
}
