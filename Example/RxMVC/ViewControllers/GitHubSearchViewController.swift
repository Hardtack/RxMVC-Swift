//
//  GitHubSearchViewController.swift
//  RxMVC
//
//  Asynchronous networking example.
//  Searchs repositories from GitHub and renders to tableview.
//  And it is also example of dividing M-V-C into multiple files.
//
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxMVC
import JLToast

class GitHubSearchViewController: UIViewController, View, UserInteractable, GitHubSearchControllerDelegate {
    typealias State = GitHubSearchState
    typealias Event = GitHubSearchEvent
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = GitHubSearchModel()
        let view = self
        let controller = GitHubSearchController(delegate: self)
        let userInteractable = self
        combineModel(model,
            withView: view,
            controller: controller,
            andUserInteractable: userInteractable)
            .addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Controller delegate functions
    
    func openURL(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}
