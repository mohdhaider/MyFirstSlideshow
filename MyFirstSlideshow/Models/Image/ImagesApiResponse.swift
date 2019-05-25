//
//  ImagesApiResponse.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

struct ImagesApiResponse {
    var arrImagesInfo: [ImageInfo]
}

extension ImagesApiResponse: Decodable {
    
    private enum DecodingKeys: String, CodingKey {
        case images
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        
        self.arrImagesInfo = try container.decode([ImageInfo].self, forKey: .images)
    }
}
