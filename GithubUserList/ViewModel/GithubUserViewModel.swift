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

private let startLoadingOffset: CGFloat = 75
private func isNearTheBottomEdge(_ contentOffset: CGPoint, _ tableView: UITableView?) -> Bool {
    guard let tableView = tableView else { return false }
    return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
}

class GithubUserViewModel {
    let disposeBag = DisposeBag()
    let tableView = UITableView()
    let users = BehaviorRelay<[GithubUserModel]>(value: [])
    private var userName: Observable<String>
    private var nextUrl: Observable<String> = Observable.just("")
    
    init(withUserNameObservable userNameObservable: Observable<String>) {
        self.userName = userNameObservable
    }
    
    private var dataSource: [GithubUserModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var loadNextPageTrigger: Observable<Void> {
        return tableView.rx.contentOffset
            .flatMap { [weak self] (offset) -> Observable<Void> in
                isNearTheBottomEdge(offset, self?.tableView) ? Observable.just(Void()) : Observable.empty()
        }
    }
    
    private lazy var page: Observable<[GithubUserModel]> = {
        func nextPage(_ previousPage: [GithubUserModel]?) -> Observable<[GithubUserModel]> {
            return nextUrl
                .subscribeOn(MainScheduler.instance)
                .do(onNext: { response in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                })
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .flatMapLatest { url in
                    return RxAlamofire
                        .requestJSON(.get, url)
                        .debug()
                        .catchError { error in
                            return Observable.never()
                        }
                }
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .map { [weak self] (response, json) -> [GithubUserModel] in
                    if let linkHeader = response.allHeaderFields["Link"] as? String, let nextUrl = self?.parseHeader(linkHeader) {
                        self?.nextUrl = Observable.just(nextUrl)
                    } else {
                        self?.nextUrl = Observable.just("")
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
                .asObservable()
        }
        
        func hasNext(_ page: [GithubUserModel]?) -> Bool {
            let result = BehaviorRelay<Bool>(value: false)
            nextUrl
                .map { !$0.isEmpty }
                .bind(to: result)
                .disposed(by: disposeBag)
            
            return result.value
        }
        
        return Observable.page(make: nextPage, while: hasNext, when: self.loadNextPageTrigger)
    }()
    
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
            .map { [weak self] (response, json) -> [GithubUserModel] in
                if let linkHeader = response.allHeaderFields["Link"] as? String, let nextUrl = self?.parseHeader(linkHeader) {
                    self?.nextUrl = Observable.just(nextUrl)
                } else {
                    self?.nextUrl = Observable.just("")
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
            .disposed(by: disposeBag)
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
