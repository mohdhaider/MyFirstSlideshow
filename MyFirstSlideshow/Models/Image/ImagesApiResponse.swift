//
//  ImagesApiResponse.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

/// A struct to parse server api response.
/// Currently we don't have sever api. We can upgrade it to handle sever response later on.
struct ImagesApiResponse {
    
    /// Array of ImageInfo struct objects
    var arrImagesInfo: [ImageInfo]
}

extension ImagesApiResponse: Decodable {
    
    /// Decoding keys that we will use to populate data into ImagesApiResponse struct.
    ///
    /// - images: String value that will map against input collection.
    private enum DecodingKeys: String, CodingKey {
        case images
    }
    
    /// Initialiser for creating array of ImageInfo objects.
    ///
    /// - Parameter decoder: A decoder that ccontains required information for populate ImagesApiResponse model
    /// - Throws: throw any exception if occured
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        
        self.arrImagesInfo = try container.decode([ImageInfo].self, forKey: .images)
    }
}
