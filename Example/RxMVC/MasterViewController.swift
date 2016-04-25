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
    case ClickItem(item: UIViewController)
}

enum MasterAction {
    
}

extension UIViewController {
    func withTitle(title: String) -> UIViewController {
        self.title = title
        return self
    }
}

struct MasterModel: ConstantModel {
    typealias Action = MasterAction
    typealias State = [UIViewController]
    
    let state: [UIViewController] = [
        UpDownViewController().withTitle("Up & Down")
    ]
}

protocol MasterControllerDelegate: class {
    func showSelectedViewController(viewController: UIViewController)
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
            self.delegate?.showSelectedViewController(item)
        }
        return Observable.empty()
    }
}

class MasterViewController: UITableViewController, View, UISplitViewControllerDelegate, MasterControllerDelegate {
    typealias Event = MasterEvent
    typealias State = [UIViewController]
    
    var disposeBag = DisposeBag()
    
    var selectedViewController: UIViewController? = nil
    
    
    func subscribe(stateStream: Observable<State>) -> Disposable {
        // Set initial detail view controller
        tableView.delegate = nil
        tableView.dataSource = nil
        
        return CompositeDisposable(disposables: [
            stateStream.bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.title
            }])
    }
    
    var eventStream: Observable<Event> {
        get {
            return [
                tableView.rx_modelSelected(UIViewController).map({vc in MasterEvent.ClickItem(item: vc)})
                ].toObservable().merge()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        
        let model = MasterModel()
        let view = self
        let controller = MasterControlelr(delegate: self)
        combineModel(model, withView: view, andController: controller).addDisposableTo(disposeBag)
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
    
    func showSelectedViewController(viewController: UIViewController) {
        self.selectedViewController = viewController
        guard let split = self.splitViewController else {return}
        split.showDetailViewController(viewController, sender: nil)
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let _ = selectedViewController else {
            return true
        }
        return false
    }
}

