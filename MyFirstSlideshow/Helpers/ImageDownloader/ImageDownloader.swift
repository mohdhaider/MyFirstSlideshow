//
//  ImageDownloader.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit

/// Helpers for providing callback to caller
private typealias ImageListner = (UIImage?) -> ()
private typealias ImageDownloadingCompletionBlock = (_ imageInfo: AnyObject?, _ error: Error?) -> ()

/// Current ongoing request container for gettig network call response and then provide infromation to
/// ImageDownloader class.
fileprivate class ImageRequestContainer {
    
    // MARK:- variables -
    
    let key: String
    let requestInfo: ImageFetchRequest
    let networkInteractor: NetworkInteractor<ImageFetchRequest>
    var listners = [ImageListner]()
    
    var isProgress: Bool = false
    
    // MARK:- Initializers -
    
    /// Initialise container with defauilt content.
    /// We are sure that we will use this only for image downlaing feature.
    /// As it do have listners that need frequest updated infroamtion.
    fileprivate init(withInteractor interactor:NetworkInteractor<ImageFetchRequest>, requestInfo info: ImageFetchRequest, key: String, listner: ImageListner?) {
        
        self.networkInteractor = interactor
        self.key = key
        self.requestInfo = info
        
        if let listnerAvail = listner {
            listners.append(listnerAvail)
        }
    }
    
    // MARK:- Class Helpers -
    
    /// Add new listner to array of listners for providng callbacks when
    /// image is downloaded.
    /// - Parameter listner: Callback closure
    fileprivate func addListner(_ listner: ImageListner?) {
        
        if let listnerAvail = listner {
            listners.append(listnerAvail)
        }
    }
    
    /// Sending input image to all listners
    ///
    /// - Parameter image: UIImage
    fileprivate func sendImageToAllListners(_ image: UIImage?) {
        
        listners.forEach { $0(image) }
        listners.removeAll()
    }
    
    // MARK:- Networking Handling -
    
    /// Fetch request image from network if it's not in progress already.
    ///
    /// - Parameter completionBlock: Completion block for caller.
    fileprivate func fetchImageFromNetwork(_ completionBlock:@escaping ImageDownloadingCompletionBlock) {
        
        if !isProgress {
            isProgress = true
            networkInteractor.request(
            requestInfo) { (info, response, error) in
                
                self.isProgress = false
                
                if let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any],
                    !self.key.isEmpty{
                    URLResponseCache().saveCachedHeaders(forKey: self.key, headers: headers)
                }
                
                if let imageFileUrl = info as? URL,
                    imageFileUrl.isFileURL {
                    
                    completionBlock(imageFileUrl as AnyObject, error)
                }
                else if let imageData = info as? Data,
                    let image = UIImage(data: imageData, scale: 1.0) {
                    
                    completionBlock(image, error)
                }
                else if let image = info as? UIImage {
                    completionBlock(image, error)
                }
                else {
                    completionBlock(nil, error)
                }
            }
        }
    }
}

/// Image downloader singleton class to handle all image features.
final class ImageDownloader {
    
    // MARK:- Variables -
    
    static let shared = ImageDownloader()
    
    /// Current downloading request holding dictionary. So that we can monitor which request are in progerss for now.
    private let requetsQueue:DispatchQueue = DispatchQueue(label: QueueLabels.imageDownloading.rawValue, attributes: .concurrent)
    private var tempOngoingRequests = [String: ImageRequestContainer]()
    private var ongoingRequests:[String: ImageRequestContainer]  {
        get {
            return requetsQueue.sync { tempOngoingRequests }
        }
        set {
            requetsQueue.async(flags: .barrier) {[weak self] in
                self?.tempOngoingRequests = newValue
            }
        }
    }
    
    // MARK:- Initializers -
    private init() {
    }
    
    // MARK:- Class Helpers -
    
    /// Get image from local cache. Fetched image from server of needed.
    /// (If image not present or expired)
    /// - Parameters:
    ///   - url: Image url
    ///   - block: Image callback closure
    func getImage(forUrl url:String, completionBlock block:((UIImage?) -> ())?) {
        
        guard !url.isEmpty else {
            block?(nil)
            return
        }
        
        /// if image is not in progress, then it will submit image
        /// downloading request send downloaded image to add needed callers.
        /// - Parameter container: Image request continer object
        func fetchImage(forRequestContainer container: ImageRequestContainer) {
            
            if !container.isProgress {
                container.fetchImageFromNetwork {[weak self] (imageinfo, error) in
                 
                    var downloadedAInfo: Any?
                    if let image = imageinfo as? UIImage {
                        downloadedAInfo = image
                    }
                    else if let url = imageinfo as? URL,
                        url.isFileURL,
                        let data = try? Data(contentsOf: url) {
                        downloadedAInfo = data
                    }
                    
                    if let info = downloadedAInfo {
                        ImageCache.shared.saveImage(info, forKey: container.key)
                    }
                    
                    ImageCache.shared.fetchImage(
                        forKey: container.key,
                        completionBlock: { (downloadedImage) in

                            container.sendImageToAllListners(downloadedImage)
                            
                            self?.ongoingRequests.removeValue(forKey: container.key)
                    })
                }
            }
        }
        
        /// Decision method wether to call image downlaod or not.
        func callImageDownloadingRequest() {
            
            if let request = ongoingRequests[url] {
                request.addListner(block)
                
                fetchImage(forRequestContainer: request)
            } else {
                let interactor = NetworkInteractor<ImageFetchRequest>()
                let requestContainer = ImageRequestContainer(withInteractor: interactor,
                                                             requestInfo: .fetch(imageUrl: url),
                                                             key: url,
                                                             listner: block)
                
                ongoingRequests[url] = requestContainer
                
                fetchImage(forRequestContainer: requestContainer)
            }
        }
        
        /// Fetch image from local cache. If image not found or expired, then send image to downloading module.
        ImageCache.shared.fetchImage(
        forKey: url) { (image) in
            
            if let imageAvail = image {
                
                if URLResponseCache().isResponseCacheExpired(forKey: url) {
                    callImageDownloadingRequest()
                }
                block?(imageAvail)
            } else {
                callImageDownloadingRequest()
            }
        }
    }
}
