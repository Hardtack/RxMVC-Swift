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
    <M: Model, V: View, C: Controller where M.State == V.State, V.Event == C.Event, C.Action == M.Action>
    (model: M, withView view: V, andController controller: C) -> Disposable {
    return view.subscribe(model.subscribe(controller.subscribe(view.eventStream)))
}