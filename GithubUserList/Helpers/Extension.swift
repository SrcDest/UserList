//
//  Extension.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension String {
    public func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    public func url() -> URL {
        let urlText = trim()
        if let url = URL(string: urlText) {
            return url
        }
        if let urlString = urlText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString) {
            return url
        }
        return NSURLComponents().url!
    }
}


extension UIImageView {
    private static var imageCache: [URL: UIImage]?
    
    private static func initImageCache() {
        UIImageView.imageCache = [:]
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didReceiveMemoryWarningNotification)
            .subscribe(onNext: { _ in
                UIImageView.imageCache = [:]
            })
    }
    
    static func loadImage(from url: URL) -> Observable<UIImage?> {
        if UIImageView.imageCache == nil { initImageCache() }
        
        if let cached = UIImageView.imageCache?[url] {
            return Observable.just(cached)
        }
        
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                if error != nil {
                    emitter.onError(error!)
                    return
                }
                
                guard let data = data else {
                    emitter.onCompleted()
                    return
                }
                
                let image = UIImage(data: data)
                if let cachable = image {
                    UIImageView.imageCache?[url] = cachable
                }
                
                emitter.onNext(image)
                emitter.onCompleted()
            })
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func setImageAsync(from url: URL, default defaultImage: UIImage? = nil) -> Disposable {
        image = defaultImage
        return UIImageView.loadImage(from: url)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] img in
                self?.image = img
                }, onError: { [weak self] err in
                    self?.image = defaultImage
            })
    }
}
