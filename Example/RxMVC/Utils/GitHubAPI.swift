//
//  GitHubAPI.swift
//  RxMVC
//
//  Simple API interface for GitHub.
//
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import RxAlamofire

/**
 Parsed GitHub respository.
 */
struct Repository {
    let name: String
    let fullName: String
    let htmlURL: String
}

public struct GitHubAPI {
    let manager: SessionManager
    
    func searchRepo(key: String) -> Observable<[Repository]> {
        let URL = Foundation.URL(string: "https://api.github.com/search/repositories")!
        return manager.rx.JSON(.get, URL, parameters: ["q": key]).map { data in
            if let data = data as? Dictionary<String, NSObject> {
                let items = data["items"]
                if let items = items as? [Dictionary<String, NSObject>] {
                    return items.map{ item in
                        let name = item["name"]?.description ?? ""
                        let fullName = item["full_name"]?.description ?? ""
                        let htmlURL = item["html_url"]?.description ?? ""
                        return Repository(name: name, fullName: fullName, htmlURL: htmlURL)
                    }
                }
            }
            return []
        }
    }
}
