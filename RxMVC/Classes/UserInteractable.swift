//
//  UserInteractable.swift
//  RxMVC
//
//  Created by 최건우 on 2016. 4. 27..
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift

public protocol UserInteractable {
    associatedtype Event // Event type
    
    func interact() -> Observable<Event>
}