//
//  ImagesViewModel.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation


/// This protocol will provide all data that we will need in image table cell.
protocol ImageCellInfoProtocol {
    var imageUrlString: String? {get}
}

class ImagesViewModel {
    
    // MARK:- variables -
    
    /// Obsever this to get indication whenever we do need to update data of view.
    lazy var souldRefresh = DataObserver<Bool>(false)
    
    /// A serial queue for accessing images in serial maaner.
    private let arrImagesSerialQueue:DispatchQueue = DispatchQueue(label: QueueLabels.imagesSerialQueue.rawValue)
    private var tempArrImages:[ImageCellInfoProtocol] = [ImageCellInfoProtocol]()
    /// An thread safe array of cell protocols. We can access this array from multiple tread in
    /// synchronous manner.
    /// Improvement: We can create a concurrent DispatchQueue instead of serial queue and we can
    /// add barrier blocks whenever we do need to write data. All read operation can safely executed
    /// in concurrent manner.
    var arrImages:[ImageCellInfoProtocol] {
        get {
            return arrImagesSerialQueue.sync { tempArrImages }
        }
        set {
            arrImagesSerialQueue.async {[weak self] in self?.tempArrImages = newValue }
        }
    }
    
    
    // MARK:- Class Helpers -
    
    /// Preparing initial data source in absence of actual data source.
    /// We can uee this function to make network call to fetch actual data from server.
    /// This function will parse all available images url into models and then provide
    /// a generic array of protocols for data accessing image info.
    /// This will also inform observers about data changes.
    func prpareDataSource() {
        
        let images: Array<String> = ["https://c1.staticflickr.com/6/5615/15570202337_0e64f5046e_k.jpg",
                                     "https://c1.staticflickr.com/4/3169/2846544061_cb7c04b46f_b.jpg",
                                     "https://i.redd.it/d8q1wkgu1awy.jpg",
                                     "http://www.kapstadt.de/webcam.jpg"]
        
        let arrImage = images.map { ["imageUrl" : $0] }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["images": arrImage], options: .prettyPrinted)
            
            let arrImagesInfo = try JSONDecoder().decode(ImagesApiResponse.self, from: jsonData)
            
            arrImages.append(contentsOf: arrImagesInfo.arrImagesInfo as [ImageCellInfoProtocol])
            
            souldRefresh.value = true
        }
        catch {
            debugPrint("error = \(error)")
        }
    }
}
