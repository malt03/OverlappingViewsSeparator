//
//  Tree.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import UIKit

final class Tree {
    private let spacing: CGFloat
    private var root = Node()
    private var nodes = [Element: Node]()
    
    enum Element: Hashable {
        case flexible(View)
        case stuck(View)
        
        var view: View {
            switch self {
            case .flexible(let view): return view
            case .stuck(let view): return view
            }
        }
    }
    
    typealias ElementWithRect = (element: Element, rect: CGRect)

    func processCollisionCombination(spacing: CGFloat, handler: (ElementWithRect, ElementWithRect) -> Void) {
        root.processCollisionCombination(spacing: spacing, handler: handler)
    }
    
    func processFlexibleViews(handler: (View) -> Void) {
        root.processElements { (element) in
            if case .flexible(let view) = element {
                handler(view)
            }
        }
    }
    
    init<S1: Sequence, S2: Sequence>(spacing: CGFloat, views: S1, stuckViews: S2) where S1.Element == UIView, S2.Element == UIView {
        self.spacing = spacing
        let flexible = AnySequence(views.lazy.compactMap({ (view) -> Element? in
            guard let view = View(view) else { return nil }
            return Element.flexible(view)
        }))
        let stuck = AnySequence(stuckViews.lazy.compactMap({ (view) -> Element? in
            guard let view = View(view) else { return nil }
            return Element.stuck(view)
        }))
        for element in [flexible, stuck].joined() {
            let view = element.view
            let morton = view.convertedRect.morton(in: view.windowSize, spacing: spacing)
            nodes[element] = root.add(element: element, morton: morton, currentLevel: 0)
        }
    }
    
    func update<S: Sequence>(views: S) where S.Element == View {
        for element in views.lazy.map({ Element.flexible($0) }) {
            let view = element.view
            let morton = view.convertedRect.morton(in: view.windowSize, spacing: spacing)
            let node = root.add(element: element, morton: morton, currentLevel: 0)
            if nodes[element] !== node {
                nodes[element]?.remove(element: element)
                nodes[element] = node
            }
        }
    }
    
    final class Node {
        func processCollisionCombination(spacing: CGFloat, handler: (ElementWithRect, ElementWithRect) -> Void) {
            for childNode in children.values {
                childNode.processCollisionCombination(spacing: spacing, handler: handler)
            }

            if elements.isEmpty { return }
            
            func handlerWithCollisionCheck(_ a: Element, _ b: Element) {
                let aRect = a.view.convertedRect
                let bRect = b.view.convertedRect
                if !aRect.isCollision(to: bRect, spacing: spacing) { return }
                handler((a, aRect), (b, bRect))
            }

            let elements = Array(self.elements)
            for i in 0..<elements.count {
                let a = elements[i]
                for j in (i + 1)..<elements.count {
                    let b = elements[j]
                    handlerWithCollisionCheck(a, b)
                }
                processChildElements { handlerWithCollisionCheck(a, $0) }
            }
        }
        
        func processElements(handler: (Element) -> Void) {
            for element in elements { handler(element) }
            processChildElements(handler: handler)
        }
        
        private func processChildElements(handler: (Element) -> Void) {
            for childNode in children.values {
                for element in childNode.elements {
                    handler(element)
                }
                childNode.processChildElements(handler: handler)
            }
        }
        
        private var parent: Node?
        private var children = [Child: Node]()
        private var elements = Set<Element>()
        private enum Child: UInt64 {
            case leftTop = 0
            case rightTop = 1
            case leftBottom = 2
            case rightBottom = 3
        }
        
        func remove(element: Element) {
            elements.remove(element)
        }
        
        func add(element: Element, morton: MortonOrder, currentLevel: Int) -> Node {
            if morton.level == currentLevel {
                elements.insert(element)
                return self
            }
            let child = Child(rawValue: (morton.number >> (62 - currentLevel * 2)) & 3)!
            return children.getOrInit(for: child).add(element: element, morton: morton, currentLevel: currentLevel + 1)
        }
    }
}

extension Dictionary where Value == Tree.Node {
    mutating func getOrInit(for key: Key) -> Value {
        if let value = self[key] { return value }
        let value = Tree.Node()
        self[key] = value
        return value
    }
}

extension CGRect {
    func isCollision(to rect: CGRect, spacing: CGFloat) -> Bool {
        minX < rect.maxX + spacing && maxX + spacing > rect.minX && minY < rect.maxY + spacing && maxY + spacing > rect.minY
    }
}
