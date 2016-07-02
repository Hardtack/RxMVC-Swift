//
//  UpDownViewController.swift
//  Examples
//
//  Created by 최건우 on 2016. 4. 22..
//  Copyright © 2016년 Choi Geonu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxMVC

public enum UpDownEvent {
    case ClickUp
    case ClickDown
    case ClickReset
}

enum UpDownAction {
    case Increase
    case Decrease
    case Reset
}

struct UpDownController: MapController {
    typealias Event = UpDownEvent
    typealias Action = UpDownAction
    func mapEventToAction(event: Event) -> Action {
        switch event {
        case .ClickUp:
            return Action.Increase
        case .ClickDown:
            return Action.Decrease
        default:
            return Action.Reset
        }
    }
}

struct UpDownModel: ReducerModel {
    typealias Action = UpDownAction
    typealias State = Int
    
    let initialState = 0
    func reduce(state: State, with action: Action) -> State {
        switch action {
        case .Increase:
            return state + 1
        case .Decrease:
            return state - 1
        case .Reset:
            return initialState
        }
    }
}

public class UpDownViewController: UIViewController, View, UserInteractable {
    public typealias Event = UpDownEvent
    public typealias State = Int
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    public func update(stateStream: Observable<State>) -> Disposable {
        return stateStream.subscribeNext { (number) in
            self.countLabel.text = "\(number)"
        }
    }
    
    public func interact() -> Observable<Event> {
        return [
            self.upButton.rx_tap.map{_ in UpDownEvent.ClickUp},
            self.downButton.rx_tap.map{_ in UpDownEvent.ClickDown},
            self.resetButton.rx_tap.map{_ in UpDownEvent.ClickReset},
            ].toObservable().merge()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let model = UpDownModel()
        let view = self
        let controller = UpDownController()
        let userInteractable = self
        combineModel(model, withView: view, controller: controller, andUserInteractable: userInteractable).addDisposableTo(disposeBag)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
