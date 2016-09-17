//
//  GitHubSearchModel.swift
//  RxMVC
//
//  GitHubSearch's model
//
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import Foundation
import RxMVC

struct GitHubSearchModel: ReducerModel {
    typealias State = GitHubSearchState
    typealias Action = GitHubSearchAction
    
    let initialState = GitHubSearchState(query: nil, repositories: RepositoriesState.some([]))
    
    func reduce(_ state: State, with action: Action) -> State {
        switch action {
        case .updateQuery(let query):
            return State(query: query, repositories: state.repositories)
        case .updateRepositories(let repositories):
            return State(query: state.query, repositories: RepositoriesState.some(repositories))
        case .repositoriesError(let error):
            return State(query: state.query, repositories: RepositoriesState.error(error))
        }
    }
}
