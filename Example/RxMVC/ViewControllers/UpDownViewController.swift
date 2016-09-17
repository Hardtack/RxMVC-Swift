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
    case clickUp
    case clickDown
    case clickReset
}

enum UpDownAction {
    case increase
    case decrease
    case reset
}

struct UpDownModel: ReducerModel {
    typealias Action = UpDownAction
    typealias State = Int
    
    let initialState = 0
    func reduce(_ state: State, with action: Action) -> State {
        switch action {
        case .increase:
            return state + 1
        case .decrease:
            return state - 1
        case .reset:
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
    
    func update(_ stateStream: Observable<State>) -> Disposable {
        return stateStream.subscribe(onNext: { (number) in
            self.countLabel.text = "\(number)"
        })
    }
    
    func interact() -> Observable<Event> {
        return Observable.from([
            self.upButton.rx.tap.map{_ in Event.clickUp},
            self.downButton.rx.tap.map{_ in Event.clickDown},
            self.resetButton.rx.tap.map{_ in Event.clickReset},
            ]).merge()
    }
}

struct UpDownController: MapController {
    typealias Event = UpDownEvent
    typealias Action = UpDownAction
    
    func mapEventToAction(_ event: Event) -> Action {
        switch event {
        case .clickUp:
            return Action.increase
        case .clickDown:
            return Action.decrease
        case .clickReset:
            return Action.reset
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
