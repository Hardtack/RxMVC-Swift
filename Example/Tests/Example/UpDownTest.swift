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
            next(210, UpDownAction.increase),
            next(220, UpDownAction.increase),
            next(230, UpDownAction.increase),
            next(240, UpDownAction.decrease),
            next(250, UpDownAction.decrease),
            next(260, UpDownAction.reset),
            next(270, UpDownAction.increase),
            completed(300)
            ])
        let res = scheduler.start { model.manipulate(actionStream: xs.asObservable()) }
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
            next(210, UpDownEvent.clickUp),
            next(220, UpDownEvent.clickDown),
            next(230, UpDownEvent.clickReset),
            completed(300)
            ])
        let res = scheduler.start { controller.use(eventStream: xs.asObservable()) }
        let expected = [
            next(210, UpDownAction.increase),
            next(220, UpDownAction.decrease),
            next(230, UpDownAction.reset),
            completed(300)
        ]
        XCTAssertEqual(res.events, expected)
    }
}
