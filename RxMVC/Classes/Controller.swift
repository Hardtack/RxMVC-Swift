//
//  Controller.swift
//  RxMVC
//
//  Created by 최건우 on 2016. 4. 22..
//  Copyright © 2016년 Choi Geonu. All rights reserved.
//

import Foundation
import RxSwift

public protocol Controller {
    associatedtype Event // Event type
    associatedtype Action // Action type
    
    func use(eventStream: Observable<Event>) -> Observable<Action>
}

public protocol MapController: Controller {
    associatedtype Event // Event type
    associatedtype Action // Action type
    
    func mapEventToAction(event: Event) -> Action
}

public extension MapController {
    func use(eventStream: Observable<Event>) -> Observable<Self.Action> {
        return eventStream.map({ (e) in
            return self.mapEventToAction(e)
        })
    }
}

public protocol FlatMapController: Controller {
    associatedtype Event // Event type
    associatedtype Action // Action type
    
    func flatMapEventToAction(event: Event) -> Observable<Action>
}

public extension FlatMapController {
    func use(eventStream: Observable<Event>) -> Observable<Self.Action> {
        return eventStream.flatMap({ (e) in
            return self.flatMapEventToAction(e)
        })
    }
}