//
//  ModelTest.swift
//  RxMVC
//
//  Test of model utilities.
//

import XCTest
import RxTests

@testable import RxMVC

struct TestModel: ReducerModel {
    enum Action {
        case increase
    }
    typealias State = Int
    
    let initialState = 1
    func reduce(state: State, with action: Action) -> State {
        switch action {
        case .increase:
            return state + 1
        }
    }
}

class ModelTest: XCTestCase {
    func testReducerModel() {
        let model = TestModel()
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(210, TestModel.Action.increase),
            next(220, TestModel.Action.increase),
            next(230, TestModel.Action.increase),
            completed(300)
            ])
        let res = scheduler.start { model.manipulate(actionStream: xs.asObservable()) }
        let expected = [
            next(200, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            completed(300)
        ]
        XCTAssertEqual(res.events, expected)
    }
}
