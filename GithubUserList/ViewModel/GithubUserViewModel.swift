//
//  GithubUserViewModel.swift
//  GithubUserList
//
//  Created by shhan on 08/05/2019.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import ObjectMapper

class GithubUserViewModel {
    
    let users = BehaviorRelay<[GithubUserModel]>(value: [])
    fileprivate var userName: Observable<String>
    
    init(withUserNameObservable userNameObservable: Observable<String>) {
        self.userName = userNameObservable
    }
    
    func fetch() {
        userName
            .subscribeOn(MainScheduler.instance)
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { text in
                return RxAlamofire
                    .requestJSON(.get, "https://api.github.com/search/users?q=\(text)")
                    .debug()
                    .catchError { error in
                        return Observable.never()
                    }
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { (response, json) -> [GithubUserModel] in
                print(response.allHeaderFields)
                if let linkHeader = response.allHeaderFields["Link"] as? String {
                    
                }
                if let userSearch = Mapper<GithubSearchUserModel>().map(JSONObject: json), let userList = userSearch.items {
                    return userList
                } else {
                    return []
                }
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            .bind(to: users)
    }
    
    func parseHeader(_ linkHeader: String) -> String {
        let links = linkHeader.components(separatedBy: ",")
        var dict: [String : String] = [:]
        links.forEach({
            let components = $0.components(separatedBy:"; ")
            let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: " <>"))
            dict[components[1]] = cleanPath
        })
        if let nextPagePath = dict["rel=\"next\""] {
            return nextPagePath
        } else {
            return ""
        }
    }
}
