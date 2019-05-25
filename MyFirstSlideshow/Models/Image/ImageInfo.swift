//
//  TYImageInfo.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

/// Struct for holding image information.
/// We can later modifiy it to hold more information related to image.
struct ImageInfo {
    
    var strImageUrl: String?
}

extension ImageInfo: Decodable {
    
    /// Decoding keys that we will use to populate data into ImageInfo struct.
    ///
    /// - imageUrl: String value that will map against input collection.
    private enum DecodingKeys: String, CodingKey {
        case imageUrl
    }
    
    /// Initialiser for creating ImageInfo object.
    ///
    /// - Parameter decoder: A decoder that ccontains required information for populate ImageInfo model
    /// - Throws: throw any exception if occured
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        
        for key in container.allKeys {
            switch key {
            case .imageUrl:
                self.strImageUrl = try? container.decode(String.self, forKey: key)
            }
        }
    }
}

extension ImageInfo: ImageCellInfoProtocol {
    
    /// Providing implementation for image URL string.
    var imageUrlString: String? {
        return strImageUrl
    }
}
