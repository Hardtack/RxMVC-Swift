//
//  UpDownTest.swift
//  RxMVC
//

import XCTest
import RxSwift
import RxBlocking
import RxTests
import RxMVC

@testable import RxMVC_Example

class UpDownTest: XCTestCase {
    func testModel() {
        let model = UpDownModel()
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(210, UpDownAction.Increase),
            next(220, UpDownAction.Increase),
            next(230, UpDownAction.Increase),
            next(240, UpDownAction.Decrease),
            next(250, UpDownAction.Decrease),
            next(260, UpDownAction.Reset),
            next(270, UpDownAction.Increase),
            completed(300)
            ])
        let res = scheduler.start { model.manipulate(xs.asObservable()) }
        let expected = [
            next(200, 0),
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 2),
            next(250, 1),
            next(260, 0),
            next(270, 1),
            completed(300)
        ]
        XCTAssertEqual(res.events, expected)
    }

    func testController() {
        let controller = UpDownController()
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(210, UpDownEvent.ClickUp),
            next(220, UpDownEvent.ClickDown),
            next(230, UpDownEvent.ClickReset),
            completed(300)
            ])
        let res = scheduler.start { controller.use(xs.asObservable()) }
        let expected = [
            next(210, UpDownAction.Increase),
            next(220, UpDownAction.Decrease),
            next(230, UpDownAction.Reset),
            completed(300)
        ]
        XCTAssertEqual(res.events, expected)
    }
}
