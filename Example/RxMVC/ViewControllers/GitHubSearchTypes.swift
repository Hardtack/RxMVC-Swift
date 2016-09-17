//
//  GitHubSearchTypes.swift
//  RxMVC
//
//  Created by Owen Choi on 2016. 7. 3..
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import Foundation

enum GitHubSearchEvent {
    case changeSearchText(String)
    case selectRepository(Repository)
}

enum GitHubSearchAction {
    case updateQuery(String?)
    case updateRepositories([Repository])
    case repositoriesError(Error)
}

enum RepositoriesState {
    case some([Repository])
    case error(Error)
}

struct GitHubSearchState {
    let query: String?
    let repositories: RepositoriesState
}
