//
//  GitHubSearchView.swift
//  RxMVC
//
//  Created by Owen Choi on 2016. 7. 6..
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxMVC
import JLToast

struct GitHubSearchView: View, UserInteractable {
    typealias State = GitHubSearchState
    typealias Event = GitHubSearchEvent
    
    let searchTextField: UITextField
    let tableView: UITableView
    
    func interact() -> Observable<Event> {
        return [
            searchTextField.rx_text.asDriver().map{text in Event.ChangeSearchText(text)}.throttle(0.5).asObservable(),
            tableView.rx_modelSelected(Repository).map{repository in Event.SelectRepository(repository)}
            ].toObservable().merge()
    }
    
    func update(stateStream: Observable<State>) -> Disposable {
        return CompositeDisposable(disposables: [
            stateStream.map{state in state.query ?? ""}.distinctUntilChanged().bindTo(searchTextField.rx_text),
            stateStream
                .map {state -> [Repository] in
                    switch(state.repositories) {
                    case .Some(let items):
                        return items as Array<Repository>
                    case .Error:
                        return []
                    }
                }
                .bindTo(tableView.rx_itemsWithCellIdentifier("Cell")) { (row, element, cell) in
                    cell.textLabel?.text = element.name
                    cell.detailTextLabel?.text = element.fullName
            },
            stateStream
                .map {state -> ErrorType? in
                    switch (state.repositories) {
                    case .Error(let error):
                        return error
                    default:
                        return nil
                    }
                }
                .asDriver(onErrorJustReturn: nil)
                .filter { error in error != nil }
                .map { error in error! }
                .throttle(1.0)
                .asObservable()
                .subscribeNext {error in
                    let error = error as NSError
                    JLToast.makeText(error.localizedDescription).show()
            }])
    }
}
