//
//  String.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation

extension String{
    
    var isEmail: Bool {
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
       let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
       return emailTest.evaluate(with: self)
    }
    
}