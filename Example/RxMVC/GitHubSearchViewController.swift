//
//  GitHubSearchViewController.swift
//  RxMVC
//
//  Created by Owen Choi on 2016. 7. 2..
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxMVC
import Alamofire

enum GitHubSearchEvent {
    case ChangeSearchText(String)
    case SelectRepository(Repository)
}

enum GitHubSearchAction {
    case UpdateQuery(String?)
    case UpdateRepositories([Repository])
}

struct GitHubSearchState {
    let query: String?
    let repositories: [Repository]
}

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
                    GitHubAPI(manager: Manager.sharedInstance).searchRepo(query).asDriver(onErrorJustReturn: []).map { repositories in
                        return Action.UpdateRepositories(repositories)
                    })
            }
        case .SelectRepository(let repository):
            if let url = NSURL(string: repository.htmlURL) {
                self.delegate?.openURL(url)
            }
            return Observable.empty()
        }
    }
}

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
            stateStream.map{state in state.repositories}
                .bindTo(tableView.rx_itemsWithCellIdentifier("Cell")) { (row, element, cell) in
                    cell.textLabel?.text = element.name
                    cell.detailTextLabel?.text = element.fullName
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
