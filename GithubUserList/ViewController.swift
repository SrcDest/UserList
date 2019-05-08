//
//  ViewController.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class ViewController: UIViewController {

    // MARK:- Properties
    
    fileprivate let userCell = "userCell"
    fileprivate let loadingCell = "loadingCell"
    fileprivate let debouncer = Debouncer(timeInterval: 0.5)
    
    var githubUserList: [[String : Any]] = []
    var selectedIndexPath: [IndexPath] = []
    var fetchingMore: Bool = false
    var nextUrl: String?
    
    // MARK: Controls
    
    let nothingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "No search results found."
        return label
    }()
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    lazy var searchTextfield: ImageTextField = {
        let textField = ImageTextField()
        textField.leftImage = #imageLiteral(resourceName: "baseline_search_black_24pt")
        textField.leftPadding = 5
        textField.backgroundColor = UIColor(hex: "#EEEEEE")
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.borderStyle = .roundedRect
        textField.delegate = self
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
        tableView.dataSource = self
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
        
        addControls()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        debouncer.handler = {
            print("Send github api request")
        }
    }
    
    // MARK: Custom functions

    func addControls() {
        self.view.addSubview(searchTextfield)
        searchTextfield.snp.makeConstraints { (m) in
            m.top.equalTo(self.view).offset(40)
            m.left.equalTo(self.view).offset(10)
            m.right.equalTo(self.view).offset(-10)
            m.height.equalTo(30)
        }
        self.view.addSubview(userTableView)
        userTableView.snp.makeConstraints { (m) in
            m.top.equalTo(searchTextfield.snp.bottom).offset(10)
            m.left.right.bottom.equalTo(self.view)
        }
        self.view.addSubview(nothingLabel)
        nothingLabel.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(self.view)
        }
        userTableView.addSubview(indicator)
        indicator.style = .white
        indicator.color = UIColor.red
        indicator.snp.makeConstraints { (m) in
            m.centerX.centerY.equalTo(self.view)
        }
    }
    
    func getGithubUserList(_ urlString: String) {
        nothingLabel.isHidden = true
        if !fetchingMore {
            indicator.startAnimating()
        }
        
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data,
                        let response = response else { return }
                if let httpResponse = response as? HTTPURLResponse {
                    if let link = httpResponse.allHeaderFields["Link"] as? String {
                        let stringArr = link.components(separatedBy: ",")
                        for string in stringArr {
                            if string.contains("rel=\"next\"") {
                                let nextUrlString = string.components(separatedBy: ";")
                                self.nextUrl = nextUrlString[0].trimmingCharacters(in: [ " ", "<", ">"])
                                break
                            }
                        }
                    } else {
                        self.nextUrl = nil
                    }
                }
                
                var json: [String : Any]?
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    if let json = json, let userList = json["items"] as? [[String : Any]] {
                        DispatchQueue.main.async {
                            if self.indicator.isAnimating {
                                self.indicator.stopAnimating()
                            }
                            if userList.count == 0 {
                                self.githubUserList.removeAll()
                                self.userTableView.reloadData()
                                self.userTableView.isHidden = true
                                self.nothingLabel.isHidden = false
                            } else {
                                if self.fetchingMore {
                                    self.githubUserList.append(contentsOf: userList)
                                    self.fetchingMore = false
                                    self.userTableView.reloadData()
                                } else {
                                    self.githubUserList = userList
                                    self.userTableView.reloadData()
                                    self.userTableView.isHidden = false
                                    self.nothingLabel.isHidden = true
                                }
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        if self.indicator.isAnimating {
                            self.indicator.stopAnimating()
                        }
                        self.githubUserList.removeAll()
                        self.userTableView.reloadData()
                        self.userTableView.isHidden = true
                        self.nothingLabel.isHidden = false
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func getUserOrgList(_ urlString: String, _ indexPath: IndexPath) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                var json: [[String : Any]]?
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]]
                    if let jsonResult = json {
                        if jsonResult.count != 0 {
                            DispatchQueue.main.async {
                                if let cell = self.userTableView.cellForRow(at: indexPath) as? UserListTableCell {
                                    cell.orgList = jsonResult
                                    cell.orgCollectionView.reloadData()
                                    cell.orgCollectionView.isHidden = false
                                    self.selectedIndexPath.append(indexPath)
                                    self.userTableView.beginUpdates()
                                    self.userTableView.endUpdates()
                                }
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.selectedIndexPath.removeAll()
                        self.userTableView.reloadData()
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @objc func didTapUserOrg(_ sender: UITapGestureRecognizer) {
        debouncer.renewInterval()
        
        if let view = sender.view {
            let indexPath = IndexPath(row: view.tag, section: 0)
            if selectedIndexPath.contains(indexPath) {
                if let arrayIndex = selectedIndexPath.firstIndex(of: indexPath) {
                    selectedIndexPath.remove(at: arrayIndex)
                    if let cell = userTableView.cellForRow(at: indexPath) as? UserListTableCell {
                        cell.orgList.removeAll()
                        cell.orgCollectionView.reloadData()
                        cell.orgCollectionView.isHidden = true
                        self.userTableView.beginUpdates()
                        self.userTableView.endUpdates()
                    }
                }
            } else {
                if let githubUserModel = GithubUserModel(JSON: githubUserList[indexPath.row]), let userNickname = githubUserModel.login {
                    let urlString = "https://api.github.com/users/" + userNickname + "/orgs"
                    getUserOrgList(urlString, indexPath)
                }
            }
        }
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

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchKeyword = textField.text else { return false }
        debouncer.renewInterval()
        
        userTableView.setContentOffset(.zero, animated: false)
        selectedIndexPath.removeAll()
        let urlString = "https://api.github.com/search/users?q=" + searchKeyword
        getGithubUserList(urlString)
        return true
    }
}

// MARK:- Table view delegate

extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            if !fetchingMore {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        if let url = nextUrl {
            fetchingMore = true
            userTableView.reloadSections(IndexSet(integer: 1), with: .none)
            getGithubUserList(url)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndexPath.contains(indexPath) {
            return 75 + 43
        } else {
            return 75
        }
    }
}

// MARK:- Table view datasource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return githubUserList.count
        } else if section == 1, fetchingMore {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! UserListTableCell
            cell.selectionStyle = .none
            if let githubUserModel = GithubUserModel(JSON: githubUserList[indexPath.row]) {
                let userNameLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapUserOrg(_:)))
                let userProfileImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapUserOrg(_:)))
                cell.userNameLabel.text = githubUserModel.login
                cell.userNameLabel.tag = indexPath.row
                cell.userNameLabel.isUserInteractionEnabled = true
                cell.userNameLabel.addGestureRecognizer(userNameLabelTap)
                if let scoreString = githubUserModel.score?.description {
                    cell.scoreLabel.text = "score: " + scoreString
                } else {
                    cell.scoreLabel.text = "score: -"
                }
                if let urlString = githubUserModel.avatar_url, let url = URL(string: urlString) {
                    cell.userProfileImageView.kf.setImage(with: url, options: [ .cacheMemoryOnly ])
                }
                cell.userProfileImageView.tag = indexPath.row
                cell.userProfileImageView.isUserInteractionEnabled = true
                cell.userProfileImageView.addGestureRecognizer(userProfileImageViewTap)
                if selectedIndexPath.contains(indexPath) {
                    cell.orgCollectionView.isHidden = false
                } else {
                    cell.orgCollectionView.isHidden = true
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.indicator.startAnimating()
            
            return cell
        }
    }
}

