//
//  UpDownViewController.swift
//  Examples
//  
//  The most simple example of RxMVC
//  Just increases/decreases a number.
//
//  Copyright © 2016년 Choi Geonu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxMVC

enum UpDownEvent {
    case ClickUp
    case ClickDown
    case ClickReset
}

enum UpDownAction {
    case Increase
    case Decrease
    case Reset
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

struct UpDownView: View, UserInteractable {
    typealias State = Int
    typealias Event = UpDownEvent
    
    let countLabel: UILabel
    let upButton: UIButton
    let downButton: UIButton
    let resetButton: UIButton
    
    func update(stateStream: Observable<State>) -> Disposable {
        return stateStream.subscribeNext { (number) in
            self.countLabel.text = "\(number)"
        }
    }
    
    func interact() -> Observable<Event> {
        return [
            self.upButton.rx_tap.map{_ in Event.ClickUp},
            self.downButton.rx_tap.map{_ in Event.ClickDown},
            self.resetButton.rx_tap.map{_ in Event.ClickReset},
            ].toObservable().merge()
    }
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
        case .ClickReset:
            return Action.Reset
        }
    }
}

class UpDownViewController: UIViewController {
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = UpDownModel()
        let view = UpDownView(countLabel: countLabel,
                              upButton: upButton,
                              downButton: downButton,
                              resetButton: resetButton)
        let controller = UpDownController()
        combineModel(model, withView: view, controller: controller).addDisposableTo(disposeBag)
    }
}
