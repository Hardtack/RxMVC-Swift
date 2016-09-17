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
import Toaster

struct GitHubSearchView: View, UserInteractable {
    typealias State = GitHubSearchState
    typealias Event = GitHubSearchEvent
    
    let searchTextField: UITextField
    let tableView: UITableView
    
    func interact() -> Observable<Event> {
        return Observable.from([
            searchTextField.rx.textInput.text.asDriver().map{text in Event.changeSearchText(text)}.throttle(0.5).asObservable(),
            tableView.rx.modelSelected(Repository.self).map{repository in Event.selectRepository(repository)}
            ]).merge()
    }
    
    func update(stateStream: Observable<State>) -> Disposable {
        return CompositeDisposable(disposables: [
            stateStream.map{state in state.query ?? ""}.distinctUntilChanged().bindTo(searchTextField.rx.textInput.text),
            stateStream
                .map {state -> [Repository] in
                    switch(state.repositories) {
                    case .some(let items):
                        return items as Array<Repository>
                    case .error:
                        return []
                    }
                }
                .bindTo(tableView.rx.items(cellIdentifier: "Cell")) { (row, element, cell) in
                    cell.textLabel?.text = element.name
                    cell.detailTextLabel?.text = element.fullName
            },
            stateStream
                .map {state -> Error? in
                    switch (state.repositories) {
                    case .error(let error):
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
                .subscribe(onNext: {error in
                    let error = error as NSError
                    Toast(text: error.localizedDescription).show()
                })])
    }
}
