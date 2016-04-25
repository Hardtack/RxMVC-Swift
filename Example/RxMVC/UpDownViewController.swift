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

public class UpDownViewController: UIViewController, View {
    public typealias Event = UpDownEvent
    public typealias State = Int
    
    let countLabel = UILabel()
    let upButton = UIButton()
    let downButton = UIButton()
    let resetButton = UIButton()
    
    var disposeBag = DisposeBag()
    
    public func subscribe(stateStream: Observable<State>) -> Disposable {
        return stateStream.subscribeNext { (number) in
            self.countLabel.text = "\(number)"
            }
    }
    
    public var eventStream: Observable<Event> {
        get {
            return [
                self.upButton.rx_tap.map{_ in UpDownEvent.ClickUp},
                self.downButton.rx_tap.map{_ in UpDownEvent.ClickDown},
                self.resetButton.rx_tap.map{_ in UpDownEvent.ClickReset},
                ].toObservable().merge()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = UpDownController()
        let model = UpDownModel()
        combineModel(model, withView: self, andController: controller).addDisposableTo(disposeBag)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
