//
//  CustomImageView.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {

    // MARK:- Variables -
    
    /// An enum for providing various kind of effects on UIImageView
    /// - none: No Effect will be applied
    /// - RounderCorner4Plx: Provide 4.0 corner radius to UIImageView at all corners
    enum ImageType: Int {
        case none = 0
        case RounderCorner4Plx
    }

    // MARK:- View Methods -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyEffects()
    }
    
    // MARK:- Class Helpers -
    
    /// Marking effects as per UIImageView tag.
    /// Please take a look at ImageType for reference.
    func applyEffects() {
        
        switch tag {
        case ImageType.RounderCorner4Plx.rawValue:
            self.layer.cornerRadius = 4.0
        default:
            break
        }
    }
}
