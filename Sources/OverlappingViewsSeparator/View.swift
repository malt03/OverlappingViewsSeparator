//
//  View.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import UIKit

final class View: Hashable {
    static func == (lhs: View, rhs: View) -> Bool { lhs.wrapped == rhs.wrapped }
    func hash(into hasher: inout Hasher) { hasher.combine(wrapped) }

    let wrapped: UIView
    private let rect: CGRect
    let windowSize: CGSize
    var translate: CGVector
    let reset: Bool
    
    var convertedRect: CGRect {
        CGRect(
            origin: rect.origin + translate,
            size: rect.size
        )
    }
    
    init?(_ view: UIView, reset: Bool) {
        guard let window = view.window else { return nil }
        let viewRect = view.convert(view.bounds, to: window)
        if reset {
            rect = viewRect.applying(view.transform.inverted())
        } else {
            rect = viewRect
        }
        self.reset = reset
        wrapped = view
        windowSize = window.bounds.size
        translate = .zero
    }
    
    func applyTransform() {
        if reset {
            wrapped.transform = CGAffineTransform(translationX: translate.dx, y: translate.dy)
        } else {
            wrapped.transform = wrapped.transform.translatedBy(x: translate.dx, y: translate.dy)
        }
    }
}
