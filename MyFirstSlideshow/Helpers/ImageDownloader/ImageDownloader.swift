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

fileprivate protocol ImageRequestDownloaderProtocol {
    func imageRequestFinished(_ image:UIImage?, error: Error?, source: ImageRequestContainer)
}

fileprivate class ImageRequestContainer {
    
    // MARK:- variables -
    
    let key: String
    let requestInfo: ImageFetchRequest
    let networkInteractor: NetworkInteractor<ImageFetchRequest>
    var listners = [ImageListner?]()
    var delegate: ImageRequestDownloaderProtocol?
    
    var isProgress: Bool = false
    
    // MARK:- Initializers -
    
    fileprivate init(withInteractor interactor:NetworkInteractor<ImageFetchRequest>, requestInfo info: ImageFetchRequest, key: String, delegate: ImageRequestDownloaderProtocol?, listner: ImageListner?) {
        
        self.networkInteractor = interactor
        self.key = key
        self.delegate = delegate
        self.requestInfo = info
        
        if let listnerAvail = listner {
            listners.append(listnerAvail)
        }
        fetchImageFromNetwork()
    }
    
    // MARK:- Class Helpers -
    
    func addListner(_ listner: ImageListner?) {
        
        if let listnerAvail = listner {
            listners.append(listnerAvail)
        }
        fetchImageFromNetwork()
    }
    
    func sendImageToAllListners(_ image: UIImage?) {
        
        listners.forEach { $0?(image) }
        listners.removeAll()
    }
    
    // MARK:- Networking Handling -
    
    func fetchImageFromNetwork() {
        weak var weakSelf = self
        if !isProgress {
            isProgress = true
            networkInteractor.request(
            requestInfo) { (info, response, error) in
                
                if let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any],
                    let key = weakSelf?.key,
                    !key.isEmpty{
                    URLResponseCache().saveCachedHeaders(forKey: key, headers: headers)
                }
                
                if let selfAvail = weakSelf {
                    
                    if let imageFileUrl = info as? URL,
                        imageFileUrl.isFileURL,
                        let image = UIImage(contentsOfFile: imageFileUrl.path) {
                        
                        selfAvail.delegate?.imageRequestFinished(image, error: error, source: selfAvail)
                    }
                    else if let imageData = info as? Data,
                        let image = UIImage(data: imageData, scale: 1.0) {
                        
                        selfAvail.delegate?.imageRequestFinished(image, error: error, source: selfAvail)
                    }
                    else {
                        selfAvail.delegate?.imageRequestFinished(nil, error: error, source: selfAvail)
                    }
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
        
        func callImageDownloadingRequest() {
            
            if let request = ongoingRequests[url] {
                request.addListner(block)
            } else {
                let interactor = NetworkInteractor<ImageFetchRequest>()
                let requestContainer = ImageRequestContainer(withInteractor: interactor,
                                                             requestInfo: .fetch(imageUrl: url, refreshPolicy: policy),
                                                             key: url,
                                                             delegate: self,
                                                             listner: block)
                
                ongoingRequests[url] = requestContainer
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

extension ImageDownloader: ImageRequestDownloaderProtocol {
    
    fileprivate func imageRequestFinished(_ image: UIImage?, error: Error?, source: ImageRequestContainer) {
        
        source.delegate = nil
        source.sendImageToAllListners(image)
        
        if let imageAvail = image {
            ImageCache.shared.saveImage(imageAvail, forKey: source.key)
        }
        
        ongoingRequests.removeValue(forKey: source.key)
    }
}
