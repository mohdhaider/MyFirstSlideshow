//
//  BindingBox.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation


/// DataObserver generic struct provides the capability of listening to value changes in any observable property.
struct DataObserver<Element> {
    
    // MARK:- variables -
    
    /// Listners, so that a single value can brodcast changes to multiple observers.
    typealias Listner = (Element) -> ()
    private var listners = [Listner]()
    
    /// this will hold actual data.
    var value: Element {
        didSet{
            listners.forEach{ $0(value) }
        }
    }
    
    // MARK:- Initializers -
    
    init(_ val: Element) {
        value = val
    }
    
    // MARK:- Helpers -
    
    /// Binding multiple observerss to value changes.
    /// So that whenever we have any value change, then we can inform all listners about it.
    /// - Parameter listner: Closure for observing value changes.
    mutating func groupBind(_ listner: Listner?) {
        
        guard let listnerAvail = listner else { return }
        
        listners.append(listnerAvail)
    }
    
    /// Binding current observer for value changes.
    /// Any previously added observer will remove first. Then we will add new observer.
    /// You can send nil for clearing any previous observer.
    /// - Parameter listner: Closure for observing value changes.
    mutating func singleBind(_ listner: Listner?) {
        
        guard let listnerAvail = listner else { return }
        
        listners.removeAll()
        listners.append(listnerAvail)
    }
}
