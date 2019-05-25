//
//  BindingBox.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

struct DataObserver<Element> {
    
    typealias Listner = (Element) -> ()
    private var listners = [Listner]()
    
    var value: Element {
        didSet{
            listners.forEach{ $0(value) }
        }
    }
    
    init(_ val: Element) {
        value = val
    }
    
    
    mutating func groupBind(_ listner: Listner?) {
        
        guard let listnerAvail = listner else { return }
        
        listners.append(listnerAvail)
    }
    
    mutating func singleBind(_ listner: Listner?) {
        
        guard let listnerAvail = listner else { return }
        
        listners.removeAll()
        listners.append(listnerAvail)
    }
}
