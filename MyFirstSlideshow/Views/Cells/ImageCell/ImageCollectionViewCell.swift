//
//  ImageCollectionViewCell.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    // MARK:- IBOutlets -
    
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: CustomImageView!
    
    // MARK:- Cell Methods -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK:- Class Helpers -
    
    func setup(_ model: ImageCellInfo?) {
        
        guard let strUrl = model?.imageUrlString, !strUrl.isEmpty else { return }

        loadingIndicator.startAnimating()
        
        model?.get(imageAtURLString: strUrl, completionBlock: {[weak self] (image) in
            
            self?.moveToMainThread({
                self?.imageView.image = image
                self?.loadingIndicator.stopAnimating()
            })
        })
    }
}
