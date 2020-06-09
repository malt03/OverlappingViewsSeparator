//
//  WeakHolder.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import Foundation

struct WeakHolder<T: AnyObject> {
    weak var value: T?
}
