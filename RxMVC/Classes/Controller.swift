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
    
    func mapToAction(event: Event) -> Action
}

public extension MapController {
    func use(eventStream: Observable<Event>) -> Observable<Self.Action> {
        return eventStream.map({ (e) in
            return self.mapToAction(event: e)
        })
    }
}

public enum FlatMapType {
    case normal
    case first
    case latest
}

public protocol FlatMapController: Controller {
    associatedtype Event // Event type
    associatedtype Action // Action type
    
    var flatMapType: FlatMapType {get}
    
    func flatMapToAction(event: Event) -> Observable<Action>
}

public extension FlatMapController {
    var flatMapType: FlatMapType {
        get {
            return FlatMapType.normal
        }
    }
    
    func use(eventStream: Observable<Event>) -> Observable<Self.Action> {
        switch flatMapType {
        case .normal:
            return eventStream.flatMap({ (e) in
                return self.flatMapToAction(event: e)
            })
        case .first:
            return eventStream.flatMapFirst({ (e) in
                return self.flatMapToAction(event: e)
            })
        case .latest:
            return eventStream.flatMapLatest({ (e) in
                return self.flatMapToAction(event: e)
            })
        }
    }
}
