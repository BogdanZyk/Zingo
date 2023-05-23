//
//  UINavigationController.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import UIKit

extension UINavigationController{
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
