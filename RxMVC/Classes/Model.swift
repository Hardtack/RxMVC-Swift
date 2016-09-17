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
    
    func manipulate(_ actionStream: Observable<Action>) -> Observable<State>
}

public protocol ConstantModel: Model {
    associatedtype Action // Action type
    associatedtype State // State type
    
    var state: State { get }
}

public extension ConstantModel {
    func manipulate(_ actionStream: Observable<Action>) -> Observable<State> {
        return Observable.of(Observable.just(state), actionStream.map({ _ in self.state})).merge()
    }
}

public protocol ReducerModel: Model {
    associatedtype Action // Action type
    associatedtype State // State type
    
    var initialState: State { get }
    func reduce(_ state: State, with action: Action) -> State
}

public extension ReducerModel {
    func manipulate(_ actionStream: Observable<Action>) -> Observable<State> {
        let initial = Observable.just(initialState)
        let reduced = actionStream.scan(initialState, accumulator: {state, action in
            return self.reduce(state, with: action)
        })
        return initial.concat(reduced)
    }
}
