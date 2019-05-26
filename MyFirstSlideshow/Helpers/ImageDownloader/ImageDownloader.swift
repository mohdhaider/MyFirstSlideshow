//
//  ImageDownloader.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit

private typealias ImageListner = (UIImage?) -> ()
private typealias ImageDownloadingCompletionBlock = (_ imageInfo: AnyObject?, _ error: Error?) -> ()

fileprivate class ImageRequestContainer {
    
    // MARK:- variables -
    
    let key: String
    let requestInfo: ImageFetchRequest
    let networkInteractor: NetworkInteractor<ImageFetchRequest>
    var listners = [ImageListner]()
    
    var isProgress: Bool = false
    
    // MARK:- Initializers -
    
    fileprivate init(withInteractor interactor:NetworkInteractor<ImageFetchRequest>, requestInfo info: ImageFetchRequest, key: String, listner: ImageListner?) {
        
        self.networkInteractor = interactor
        self.key = key
        self.requestInfo = info
        
        if let listnerAvail = listner {
            listners.append(listnerAvail)
        }
    }
    
    // MARK:- Class Helpers -
    
    func addListner(_ listner: ImageListner?) {
        
        if let listnerAvail = listner {
            listners.append(listnerAvail)
        }
    }
    
    func sendImageToAllListners(_ image: UIImage?) {
        
        listners.forEach { $0(image) }
        listners.removeAll()
    }
    
    // MARK:- Networking Handling -
    
    func fetchImageFromNetwork(_ completionBlock:@escaping ImageDownloadingCompletionBlock) {
        
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

final class ImageDownloader {
    
    // MARK:- Variables -
    
    static let shared = ImageDownloader()
    
    private let requetsQueue:DispatchQueue = DispatchQueue(label: "com.Yoti.ImageDownloadingRequestQueue", attributes: .concurrent)
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
    
    func getImage(forUrl url:String, withRefreshPolicy policy: ImageRefreshPolicy, completionBlock block:((UIImage?) -> ())?) {
        
        guard !url.isEmpty else {
            block?(nil)
            return
        }
        
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
        
        func callImageDownloadingRequest() {
            
            if let request = ongoingRequests[url] {
                request.addListner(block)
                
                fetchImage(forRequestContainer: request)
            } else {
                let interactor = NetworkInteractor<ImageFetchRequest>()
                let requestContainer = ImageRequestContainer(withInteractor: interactor,
                                                             requestInfo: .fetch(imageUrl: url, refreshPolicy: policy),
                                                             key: url,
                                                             listner: block)
                
                ongoingRequests[url] = requestContainer
                
                fetchImage(forRequestContainer: requestContainer)
            }
        }
        
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
