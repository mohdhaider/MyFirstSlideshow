//
//  NSObjectAdditions.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

extension NSObject {
    
    /// This is a helper method to move control to application main thread asynchronously.
    ///
    /// - Parameter block: main thread call back block
    func moveToMainThread(_ block:(() -> ())?) {
        
        if Thread.isMainThread {
            block?()
        } else {
            DispatchQueue.main.async {
                block?()
            }
        }
    }
}
