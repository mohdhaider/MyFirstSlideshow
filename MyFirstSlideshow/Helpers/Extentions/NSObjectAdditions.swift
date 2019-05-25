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


/** We might need to fetch image for any source.
 It can be UIImageView, UITableViewCell or any reference type.
 So we are confirming MySuperCacheProtocol to NSObject to get default
 implementation available for all classes.
 If we need to work it with struct or any value type, then we do
 need to confirm it with that also on later requirement.
*/
extension NSObject: MySuperCacheProtocol {
}
