//
//  View.swift
//  RxMVC
//
//  Created by 최건우 on 2016. 4. 22..
//  Copyright © 2016년 Choi Geonu. All rights reserved.
//

import Foundation
import RxSwift


public protocol View {
    associatedtype State // State type
    associatedtype Event // Event type
    
    func subscribe(stateStream: Observable<State>) -> Disposable
    var eventStream: Observable<Event> { get }
}