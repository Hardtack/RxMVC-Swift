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
    
    let initialState = GitHubSearchState(query: nil, repositories: [])
    
    func reduce(state: State, with action: Action) -> State {
        switch action {
        case .UpdateQuery(let query):
            return State(query: query, repositories: state.repositories)
        case .UpdateRepositories(let repositories):
            return State(query: state.query, repositories: repositories)
        }
    }
}