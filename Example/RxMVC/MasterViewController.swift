//
//  MasterViewController.swift
//  Examples
//
//  Created by 최건우 on 2016. 4. 22..
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
        NameAndSegue(name: "Up & Down", segue: "ShowUpDown")
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

class MasterViewController: UITableViewController, UserInteractable, View, UISplitViewControllerDelegate, MasterControllerDelegate {
    typealias Event = MasterEvent
    typealias State = [NameAndSegue]
    
    var disposeBag = DisposeBag()
    
    var selectedViewController: UIViewController? = nil
    
    
    func update(stateStream: Observable<State>) -> Disposable {
        return CompositeDisposable(disposables: [
            stateStream.bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.name
            }])
    }
    
    func interact() -> Observable<Event> {
        return [
            tableView.rx_modelSelected(NameAndSegue).map({vc in MasterEvent.ClickItem(item: vc)})
            ].toObservable().merge()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        // Set initial detail view controller
        tableView.delegate = nil
        tableView.dataSource = nil
        
        let model = MasterModel()
        let view = self
        let controller = MasterControlelr(delegate: self)
        let userInteracbable = self
        combineModel(model, withView: view, controller: controller, andUserInteractable: userInteracbable).addDisposableTo(disposeBag)
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

