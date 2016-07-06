//
//  MasterViewController.swift
//  Examples
//
//  Entry point of application.
//  It shows that how controller treat actions that can not be done without UIViewController. 
//
//  Copyright © 2016년 Choi Geonu. All rights reserved.
//

import UIKit
import RxSwift
import RxMVC

enum MasterEvent {
    case ClickItem(item: NameAndSegue)
}

enum MasterAction {
    
}

struct NameAndSegue {
    let name: String
    let segue: String
}

struct MasterModel: ConstantModel {
    typealias Action = MasterAction
    typealias State = [NameAndSegue]
    
    let state: [NameAndSegue] = [
        NameAndSegue(name: "Up & Down", segue: "ShowUpDown"),
        NameAndSegue(name: "GitHub Search", segue: "ShowGitHubSearch")
    ]
}

protocol MasterControllerDelegate: class {
    func performSelectedSegue(segue: String)
}

struct MasterControlelr: FlatMapController {
    typealias Event = MasterEvent
    typealias Action = MasterAction
    
    weak var delegate: MasterControllerDelegate?
    
    init(delegate: MasterControllerDelegate) {
        self.delegate = delegate
    }
    
    
    func flatMapEventToAction(event: Event) -> Observable<Action> {
        switch event {
        case .ClickItem(let item):
            self.delegate?.performSelectedSegue(item.segue)
        }
        return Observable.empty()
    }
}

struct MasterView: View {
    typealias State = [NameAndSegue]
    let tableView: UITableView
    
    func update(stateStream: Observable<State>) -> Disposable {
        return CompositeDisposable(disposables: [
            stateStream.bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.name
            }])
    }
}

struct MasterUserInteractable: UserInteractable {
    typealias Event = MasterEvent
    let tableView: UITableView
    
    func interact() -> Observable<Event> {
        return [
            tableView.rx_modelSelected(NameAndSegue).map({vc in MasterEvent.ClickItem(item: vc)})
            ].toObservable().merge()
    }
}

class MasterViewController: UITableViewController, UISplitViewControllerDelegate, MasterControllerDelegate {
    var disposeBag = DisposeBag()
    
    var selectedViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        // Set initial detail view controller
        tableView.delegate = nil
        tableView.dataSource = nil
        
        let model = MasterModel()
        let view = MasterView(tableView: tableView)
        let controller = MasterControlelr(delegate: self)
        let userInteractable = MasterUserInteractable(tableView: tableView)
        combineModel(model, withView: view, controller: controller, andUserInteractable: userInteractable)
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Controller delegate functions
    func performSelectedSegue(segue: String) {
        performSegueWithIdentifier(segue, sender: self)
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let _ = selectedViewController else {
            return true
        }
        return false
    }
}

