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
    
    enum CellType: Int {
        case none = 0
        case RounderCorner4Plx
    }

    // MARK:- View Methods -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyEffects()
    }
    
    // MARK:- Class Helpers -
    
    func applyEffects() {
        
        switch tag {
        case CellType.RounderCorner4Plx.rawValue:
            self.layer.cornerRadius = 4.0
        default:
            break
        }
    }
}
