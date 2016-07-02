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

class UpDownViewController: UIViewController, View, UserInteractable {
    enum Event {
        case ClickUp
        case ClickDown
        case ClickReset
    }
    
    enum Action {
        case Increase
        case Decrease
        case Reset
    }
    
    typealias State = Int
    
    struct UpDownController: MapController {
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
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var disposeBag = DisposeBag()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = UpDownModel()
        let view = self
        let controller = UpDownController()
        let userInteractable = self
        combineModel(model, withView: view, controller: controller, andUserInteractable: userInteractable).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
