//
//  WeakHolder.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import Foundation

struct WeakHolder<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}

extension WeakHolder: Equatable where T: Equatable {}
extension WeakHolder: Hashable where T: Hashable {}
