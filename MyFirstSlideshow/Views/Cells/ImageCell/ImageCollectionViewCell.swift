//
//  ImageCollectionViewCell.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import UIKit

/// A reusable cell class to show rounded corner image and loading indicator.
class ImageCollectionViewCell: UICollectionViewCell {

    // MARK:- IBOutlets -

    /// A loading indicator that will automatiacally hide when image appear.
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    /// An 4.0 radius round corner image for showing image for provided url.
    @IBOutlet private weak var imageView: CustomImageView!
    
    // MARK:- Cell Methods -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK:- Class Helpers -
    
    /// Update image of cell. If image is not available,
    /// then a loading indicator will keep spinning.
    /// - Parameter model: Cell info protocol
    func setup(_ model: ImageCellInfoProtocol?) {
        
        imageView.image = nil
        
        guard let strUrl = model?.imageUrlString, !strUrl.isEmpty else { return }

        loadingIndicator.startAnimating()
        
        self.get(imageAtURLString: strUrl, completionBlock: {[weak self] (image) in
            
            self?.moveToMainThread({
                if let image = image {
                    self?.imageView.image = image
                    self?.loadingIndicator.stopAnimating()
                }
            })
        })
    }
}
