//
//  MySuperCacheProtocol.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit


/// This protocol will provide feature to get image asynchronously.
protocol MySuperCacheProtocol {
    func get(imageAtURLString imageURLString: String, completionBlock: (UIImage?) -> Void)
}

extension MySuperCacheProtocol {

    /// The default implementation of this protocol function provides
    /// the generalized implementation for getting image corresponds to an image URL.
    /// - Parameters:
    ///   - imageURLString: Complete image url as String
    ///   - completionBlock: Provide image for image url asynchronously
    func get(imageAtURLString imageURLString: String, completionBlock: (UIImage?) -> Void) {
        
        
    }
}
