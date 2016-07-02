//
//  GitHubSearchController.swift
//  RxMVC
//
//  GitHubSearch's asynchronous controller.
//
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxMVC


protocol GitHubSearchControllerDelegate: class {
    func openURL(url: NSURL)
}

struct GitHubSearchController: FlatMapController {
    typealias Event = GitHubSearchEvent
    typealias Action = GitHubSearchAction
    
    var flatMapType = FlatMapType.Latest
    
    weak var delegate: GitHubSearchControllerDelegate?
    
    init(delegate: GitHubSearchControllerDelegate) {
        self.delegate = delegate
    }
    
    func flatMapEventToAction(event: Event) -> Observable<Action> {
        switch event {
        case .ChangeSearchText(let text):
            let query = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if query == "" {
                return Observable.of(Action.UpdateQuery(nil), Action.UpdateRepositories([]))
            } else {
                return Observable.just(Action.UpdateQuery(query)).concat(
                    GitHubAPI(manager: Manager.sharedInstance).searchRepo(query).map { repositories in
                        return Action.UpdateRepositories(repositories)
                    }.asDriver(onErrorRecover: { (error) -> Driver<Action> in
                        return Driver.just(Action.RepositoriesError(error))
                    }))
            }
        case .SelectRepository(let repository):
            if let url = NSURL(string: repository.htmlURL) {
                self.delegate?.openURL(url)
            }
            return Observable.empty()
        }
    }
}