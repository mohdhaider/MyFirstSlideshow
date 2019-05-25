//
//  TYImageInfo.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

struct ImageInfo {
    
    var strImageUrl: String?
}

extension ImageInfo: Decodable {
    
    private enum DecodingKeys: String, CodingKey {
        case imageUrl
    }
    
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

extension ImageInfo: ImageCellInfo {
    
    var imageUrlString: String? {
        return strImageUrl
    }
}
