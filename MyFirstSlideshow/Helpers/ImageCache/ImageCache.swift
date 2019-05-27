//
//  ImageCache.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit


/// Application image custom cache to save and retrieve image from cache directory. Max cache capicity is 10000.
final class ImageCache: NSObject {
    
    // MARK:- variables -
    
    static let shared = ImageCache()
    let maxCacheCapicity = 10000
    
    /// Concurrent queue to access LRU cache.
    private let cacheQueue:DispatchQueue = DispatchQueue(label: "com.Yoti.lruCacheQueue", attributes: .concurrent)
    private var cache: LRUCache<String, URL>?
    
    // MARK:- Initializers -
    
    private override init() {
        super.init()
        setupCache()
    }
    
    deinit {
        
    }
    
    // MARK:- Notifications -
    
    func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(diskSpaceAlmostFull),
            name: Notification.Name.NSBundleResourceRequestLowDiskSpace,
            object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name.NSBundleResourceRequestLowDiskSpace,
            object: nil)
    }
    
    @objc func diskSpaceAlmostFull() {
        moveToMainThread {[weak self] in
            self?.clearAllCache()
        }
    }
    
    // MARK:- Class Helpers -
    
    /// We do need to prepare LRU cache to existing cached image if we do have any before it's actual use.
    func setupCache() {
        
        cacheQueue.async(flags: .barrier) {[weak self] in
            self?.cache = LRUCache<String, URL>(withCapicity: self?.maxCacheCapicity ?? 0, cacheType: .imageCache)
        }
    }

    /// Access LRU cache and give cached image in completion block.
    ///
    /// - Parameters:
    ///   - key: cached image idetifier
    ///   - block: image fetching completion block
    func fetchImage(forKey key: String, completionBlock block:((UIImage?) -> ())?) {
        
        cacheQueue.async {[weak self] in
        
            let md5 = key.md5()
            
            if let imageFileUrl = self?.cache?.getValue(forKey: md5) {
                
                if let image = UIImage(contentsOfFile: imageFileUrl.path) {
                    block?(image)
                } else {
                    self?.cache?.removeValue(forKey: md5)
                    block?(nil)
                }
            }else {
                block?(nil)
            }
        }
    }
    
    /// Save image in serial manner. We do need to work on FileManager that
    /// might be in access currently. So we need to make sure that any changes in
    /// FileManager should be in serial manner.
    /// - Parameters:
    ///   - image: UIImage/FileURL object
    ///   - key: caching image idetifier
    func saveImage(_ image: Any, forKey key: String) {
        
        cacheQueue.async(flags: .barrier) {[weak self] in
            
            let md5 = key.md5()
            
            do {
                try FileManager.default.saveImage(
                    image,
                    imageName: md5, { (url) in
                        if let imageUrl = url,
                            let success = self?.cache?.setValue(imageUrl, forKey: md5),
                            !success{
                            
                            /// We are not handlng this error because image is already saved and
                            /// we are trying to remove it but if we get any error while removing
                            /// it then we can't makes recursive calls. So cachig is
                            /// getting saved in cache directory. So we can rely of iOS to remove
                            /// cache as iOS needed later period of time.
                            try? FileManager.default.removeImage(md5)
                        }
                })
            }
            catch {
                print(ImageCacheErrors.ImageCachingFailed.rawValue)
                print(error.localizedDescription)
            }
        }
    }
    
    func clearAllCache() {

        cacheQueue.async(flags: .barrier) {[weak self] in
            try? FileManager.default.clearCachedImages()
            self?.cache?.clearLRUCache()
        }
    }
}

/// ImageCache operations errors
///
/// - ImageCachingFailed: Saving of image in FileManager failed due to some reason.
enum ImageCacheErrors: String, Error {
    case ImageCachingFailed
}
