//
//  MySuperCacheProtocol.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit

protocol MySuperCacheProtocol {
    
    func get(imageAtURLString imageURLString: String, completionBlock: (UIImage?) -> Void)
}

extension MySuperCacheProtocol {
    
    func get(imageAtURLString imageURLString: String, completionBlock: (UIImage?) -> Void) {
        
        
    }
}
