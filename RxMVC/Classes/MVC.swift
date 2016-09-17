//
//  MVC.swift
//  RxMVC
//
//  Created by 최건우 on 2016. 4. 22..
//  Copyright © 2016년 Choi Geonu. All rights reserved.
//

import Foundation
import RxSwift

public func combineModel
    <M: Model, V: View, U: UserInteractable, C: Controller>
    (_ model: M, withView view: V, controller: C, andUserInteractable userInteractable: U) -> Disposable where
    M.State == V.State, U.Event == C.Event, C.Action == M.Action {
        let eventStream = userInteractable.interact()
        let actionStream = controller.use(eventStream: eventStream)
        let stateStream = model.manipulate(actionStream: actionStream)
        return view.update(stateStream: stateStream)
}


public func combineModel
    <M: Model, V: View, C: Controller>
    (_ model: M, withView view: V, controller: C) -> Disposable where
    V: UserInteractable, M.State == V.State, V.Event == C.Event, C.Action == M.Action {
    return combineModel(model, withView: view, controller: controller, andUserInteractable: view)
}
