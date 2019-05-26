//
//  DateAdditions.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

extension Date {
    
    func dateComponents(toDate date:Any, dateFormat format: String) -> DateComponents? {
        
        var components: DateComponents?
        var toDate: Date?
        if let date = date as? Date {
            toDate = date
        }
        else if let strDate = date as? String,
            !strDate.isEmpty,
            !format.isEmpty{
            
            let formatter = DateFormatter()
            formatter.dateFormat = format
            toDate = formatter.date(from: strDate)
        }
        
        if let toDate = toDate {
            let calendar = Calendar(identifier: .gregorian)
            components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: toDate)
        }
        return components
    }
}
