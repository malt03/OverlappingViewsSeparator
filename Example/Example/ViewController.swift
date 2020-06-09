//
//  ViewController.swift
//  Example
//
//  Created by Koji Murata on 2020/06/08.
//  Copyright © 2020 Koji Murata. All rights reserved.
//

import UIKit
import OverlappingViewsSeparator

class ViewController: UIViewController {
    private let separator = OverlappingViewsSeparator(minSpacing: 8)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for _ in 0..<100 {
            let width = CGFloat.random(in: 20..<100)
            let height = CGFloat.random(in: 20..<100)
            let v = UIView(frame: CGRect(
                x: CGFloat.random(in: 0..<(view.bounds.width - width)),
                y: CGFloat.random(in: 0..<(view.bounds.height - height)),
                width: width,
                height: height)
            )
            v.backgroundColor = UIColor(
                hue: CGFloat.random(in: 0..<1),
                saturation: 1,
                brightness: 1,
                alpha: 0.8
            )
            view.addSubview(v)
            separator.register(view: v)
        }
    }
    
    @IBAction private func apply() {
        UIView.animate(withDuration: 1) {
            self.separator.apply()
        }
    }
    
    @IBAction private func reset() {
        UIView.animate(withDuration: 1) {
            self.separator.reset()
        }
    }
}

