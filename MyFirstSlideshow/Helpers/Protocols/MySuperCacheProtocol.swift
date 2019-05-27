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
    func get(imageAtURLString imageURLString: String, completionBlock: @escaping (UIImage?) -> Void)
}

extension MySuperCacheProtocol where Self: NSObject {

    /// The default implementation of this protocol function provides
    /// the generalized implementation for getting image corresponds to an image URL.
    /// - Parameters:
    ///   - imageURLString: Complete image url as String
    ///   - completionBlock: Provide image for image url asynchronously
    func get(imageAtURLString imageURLString: String, completionBlock: @escaping (UIImage?) -> Void) {
        
        ImageDownloader.shared.getImage(
        forUrl: imageURLString) { (image) in
            completionBlock(image)
        }
    }
}
