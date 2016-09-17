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
    func openURL(url: URL)
}

struct GitHubSearchController: FlatMapController {
    typealias Event = GitHubSearchEvent
    typealias Action = GitHubSearchAction
    
    var flatMapType = FlatMapType.latest
    
    weak var delegate: GitHubSearchControllerDelegate?
    
    init(delegate: GitHubSearchControllerDelegate) {
        self.delegate = delegate
    }
    
    func flatMapToAction(event: Event) -> Observable<Action> {
        switch event {
        case .changeSearchText(let text):
            let query = text.trimmingCharacters(in: CharacterSet.whitespaces)
            if query == "" {
                return Observable.of(Action.updateQuery(nil), Action.updateRepositories([]))
            } else {
                return Observable.just(Action.updateQuery(query)).concat(
                    GitHubAPI(manager: SessionManager.default).searchRepo(key: query).map { repositories in
                        return Action.updateRepositories(repositories)
                    }.asDriver(onErrorRecover: { (error) -> Driver<Action> in
                        return Driver.just(Action.repositoriesError(error))
                    }))
            }
        case .selectRepository(let repository):
            if let url = URL(string: repository.htmlURL) {
                self.delegate?.openURL(url: url)
            }
            return Observable.empty()
        }
    }
}
