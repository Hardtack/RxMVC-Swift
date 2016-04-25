//
//  Model.swift
//  RxMVC
//
//  Created by 최건우 on 2016. 4. 22..
//  Copyright © 2016년 Choi Geonu. All rights reserved.
//

import Foundation
import RxSwift

public protocol Model {
    associatedtype Action // Action type
    associatedtype State // State type
    
    func subscribe(actionStream: Observable<Action>) -> Observable<State>
}

public protocol ConstantModel: Model {
    associatedtype Action // Action type
    associatedtype State // State type
    
    var state: State { get }
}

public extension ConstantModel {
    func subscribe(actionStream: Observable<Action>) -> Observable<State> {
        return Observable.just(self.state)
    }
}

public protocol ReducerModel: Model {
    associatedtype Action // Action type
    associatedtype State // State type
    
    var initialState: State { get }
    func reduce(state: State, with action: Action) -> State
}

public extension ReducerModel {
    func subscribe(actionStream: Observable<Action>) -> Observable<State> {
        return actionStream.scan(initialState, accumulator: {state, action in
            return self.reduce(state, with: action)
        })
    }
}