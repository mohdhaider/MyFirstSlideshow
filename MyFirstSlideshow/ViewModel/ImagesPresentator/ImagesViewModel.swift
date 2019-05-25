//
//  ImagesViewModel.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

protocol ImageCellInfo: MySuperCacheProtocol {
    var imageUrlString: String? {get}
}

class ImagesViewModel {
    
    // MARK:- variables -
    
    lazy var souldRefresh = DataObserver<Bool>(false)
    
    private let arrImagesSerialQueue:DispatchQueue = DispatchQueue(label: "com.Yoti.ImagesSerialQueue")
    private var tempArrImages:[ImageCellInfo] = [ImageCellInfo]()
    var arrImages:[ImageCellInfo] {
        get {
            return arrImagesSerialQueue.sync { tempArrImages }
        }
        set {
            arrImagesSerialQueue.async {[weak self] in self?.tempArrImages = newValue }
        }
    }
    
    
    // MARK:- Class Helpers -
    
    func prpareDataSource() {
        
        let images: Array<String> = ["https://c1.staticflickr.com/6/5615/15570202337_0e64f5046e_k.jpg",
                                     "https://c1.staticflickr.com/4/3169/2846544061_cb7c04b46f_b.jpg",
                                     "https://i.redd.it/d8q1wkgu1awy.jpg",
                                     "http://www.kapstadt.de/webcam.jpg"]
        
        let arrImage = images.map { ["imageUrl" : $0] }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["images": arrImage], options: .prettyPrinted)
            
            let arrImagesInfo = try JSONDecoder().decode(ImagesApiResponse.self, from: jsonData)
            
            arrImages.append(contentsOf: arrImagesInfo.arrImagesInfo as [ImageCellInfo])
            
            print(arrImages)
            
            souldRefresh.value = true
        }
        catch {
            print("error = \(error)")
        }
    }
}
