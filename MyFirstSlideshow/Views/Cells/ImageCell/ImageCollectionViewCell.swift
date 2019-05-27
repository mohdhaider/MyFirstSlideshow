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
    
    // MARK:- Variables -
    
    private typealias ImageCallBack = (UIImage?) -> Void
    
    private var callBack:(ImageCallBack)?
    
    private var cellInfo:ImageCellInfoProtocol?
    
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
        
        cellInfo = model
        callBack = {[weak self] (image) in
            /* Here we are capturing image url. So that on getting frequent callBacks
             due to cell resue feature. We can identify correct cell for image and
             can show accordingly.
            */
            let imageUrl = strUrl
            
            self?.moveToMainThread({
                
                if imageUrl == self?.cellInfo?.imageUrlString {
                    
                    if let image = image {
                        self?.imageView.image = image
                        self?.loadingIndicator.stopAnimating()
                    }
                }
                
            })
        }
        
        if let callBackAvail = callBack {
            self.get(imageAtURLString: strUrl, completionBlock: callBackAvail)
        }
    }
}
