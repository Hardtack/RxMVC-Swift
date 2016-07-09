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
        case Increase
    }
    typealias State = Int
    
    let initialState = 1
    func reduce(state: State, with action: Action) -> State {
        switch action {
        case .Increase:
            return state + 1
        }
    }
}

class ModelTest: XCTestCase {
    func testReducerModel() {
        let model = TestModel()
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(210, TestModel.Action.Increase),
            next(220, TestModel.Action.Increase),
            next(230, TestModel.Action.Increase),
            completed(300)
            ])
        let res = scheduler.start { model.manipulate(xs.asObservable()) }
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
