//
//  GitHubSearchTypes.swift
//  RxMVC
//
//  Created by Owen Choi on 2016. 7. 3..
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import Foundation

enum GitHubSearchEvent {
    case ChangeSearchText(String)
    case SelectRepository(Repository)
}

enum GitHubSearchAction {
    case UpdateQuery(String?)
    case UpdateRepositories([Repository])
    case RepositoriesError(ErrorType)
}

enum RepositoriesState {
    case Some([Repository])
    case Error(ErrorType)
}

struct GitHubSearchState {
    let query: String?
    let repositories: RepositoriesState
}