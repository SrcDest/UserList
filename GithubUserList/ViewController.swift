//
//  ViewController.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class ViewController: UIViewController {

    // MARK:- Properties
    
    fileprivate let userCell = "userCell"
    fileprivate let loadingCell = "loadingCell"
    let disposeBag = DisposeBag()
    var githubUserViewModel: GithubUserViewModel!
    
    var searchText: Observable<String> {
        return searchTextfield.rx.text.orEmpty
            .filter { $0.count > 0 }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    // MARK: Controls
    
    let nothingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "No search results found."
        return label
    }()
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    let searchTextfield: ImageTextField = {
        let textField = ImageTextField()
        textField.leftImage = #imageLiteral(resourceName: "baseline_search_black_24pt")
        textField.leftPadding = 5
        textField.backgroundColor = UIColor(hex: "#EEEEEE")
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.borderStyle = .roundedRect
        textField.placeholder = "Input Github user nickname !"
        
        return textField
    }()
    lazy var userTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(UserListTableCell.self, forCellReuseIdentifier: userCell)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCell)
        tableView.delegate = self
        return tableView
    }()
    
    // MARK:- Functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindViews()
        githubUserViewModel.fetch()
    }
    
    // MARK: Custom functions

    func setupViews() {
        view.addSubview(searchTextfield)
        searchTextfield.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(40)
            m.left.equalTo(view).offset(10)
            m.right.equalTo(view).offset(-10)
            m.height.equalTo(30)
        }
        view.addSubview(userTableView)
        userTableView.snp.makeConstraints { (m) in
            m.top.equalTo(searchTextfield.snp.bottom).offset(10)
            m.left.right.bottom.equalTo(view)
        }
        view.addSubview(nothingLabel)
        nothingLabel.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(view)
        }
        userTableView.addSubview(indicator)
        indicator.style = .white
        indicator.color = UIColor.red
        indicator.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(view)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func bindViews() {
        githubUserViewModel = GithubUserViewModel(withUserNameObservable: searchText)
        githubUserViewModel.users
            .observeOn(MainScheduler.instance)
            .bind(to: userTableView.rx.items(cellIdentifier: userCell, cellType: UserListTableCell.self)) { _, data, cell in
                cell.setData(data)
            }
            .disposed(by: disposeBag)
        
        userTableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                self?.userTableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            userTableView.snp.remakeConstraints { (m) in
                m.top.equalTo(searchTextfield.snp.bottom).offset(10)
                m.left.right.equalTo(self.view)
                m.bottom.equalTo(self.view).offset(-keyboardSize.height)
            }
            
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        userTableView.snp.remakeConstraints { (m) in
            m.top.equalTo(searchTextfield.snp.bottom).offset(10)
            m.left.right.bottom.equalTo(self.view)
        }
        
        view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK:- Text field delegate

//extension ViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        guard let searchKeyword = textField.text else { return false }
//        debouncer.renewInterval()
//
//        userTableView.setContentOffset(.zero, animated: false)
//        selectedIndexPath.removeAll()
//        let urlString = "https://api.github.com/search/users?q=" + searchKeyword
//        getGithubUserList(urlString)
//        return true
//    }
//}

// MARK:- Table view delegate

extension ViewController: UITableViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//
//        if offsetY > contentHeight - scrollView.frame.size.height {
//            if !fetchingMore {
//                beginBatchFetch()
//            }
//        }
//    }
//    
//    func beginBatchFetch() {
//        if let url = nextUrl {
//            fetchingMore = true
//            userTableView.reloadSections(IndexSet(integer: 1), with: .none)
//            getGithubUserList(url)
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if selectedIndexPath.contains(indexPath) {
//            return 75 + 43
//        } else {
            return 75
//        }
    }
}

// MARK:- Table view datasource

//extension ViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return githubUserList.count
//        } else if section == 1, fetchingMore {
//            return 1
//        }
//
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! UserListTableCell
//            cell.selectionStyle = .none
//            if let githubUserModel = GithubUserModel(JSON: githubUserList[indexPath.row]) {
//                let userNameLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapUserOrg(_:)))
//                let userProfileImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapUserOrg(_:)))
//                cell.userNameLabel.text = githubUserModel.login
//                cell.userNameLabel.tag = indexPath.row
//                cell.userNameLabel.isUserInteractionEnabled = true
//                cell.userNameLabel.addGestureRecognizer(userNameLabelTap)
//                if let scoreString = githubUserModel.score?.description {
//                    cell.scoreLabel.text = "score: " + scoreString
//                } else {
//                    cell.scoreLabel.text = "score: -"
//                }
//                if let urlString = githubUserModel.avatar_url, let url = URL(string: urlString) {
//                    cell.userProfileImageView.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
//                }
//                cell.userProfileImageView.tag = indexPath.row
//                cell.userProfileImageView.isUserInteractionEnabled = true
//                cell.userProfileImageView.addGestureRecognizer(userProfileImageViewTap)
//                if selectedIndexPath.contains(indexPath) {
//                    cell.orgCollectionView.isHidden = false
//                } else {
//                    cell.orgCollectionView.isHidden = true
//                }
//            }
//
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
//            cell.indicator.startAnimating()
//
//            return cell
//        }
//    }
//}

