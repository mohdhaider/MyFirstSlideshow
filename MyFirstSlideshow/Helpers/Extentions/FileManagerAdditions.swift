//
//  FileManagerAdditions.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit

enum FileManagerErrors: String, Error {
    case CacheDirectoryFolderNotCreated
}

extension FileManager {
    
    /// Cache directory for imaeg cache folder
    ///
    /// - Returns: Cache directory url
    /// - Throws: throw error if occured
    func getCacheDirectorWithImagesFolder() throws -> URL? {
        
        do {
            let cachedDirectory = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("CachedImages")
            
            if !self.fileExists(atPath: cachedDirectory.path) {
                try self.createDirectory(at: cachedDirectory, withIntermediateDirectories: false, attributes: nil)
            }
            
            return cachedDirectory
        }
        catch {
            throw FileManagerErrors.CacheDirectoryFolderNotCreated
        }
    }
    
    /// Save inout object(Image Data, Image Path, UIImage object) as image
    /// in Cache directory.
    /// - Parameters:
    ///   - imageinfo: image content
    ///   - name: image name
    ///   - completion: saved image path
    /// - Throws: throw any error if occured
    func saveImage(_ imageinfo: Any, imageName name: String, _ completion:((_ imagePath: URL?) -> ())?) throws {

        do {
            if let cacheFolder = try getCacheDirectorWithImagesFolder() {
                
                let filePath = cacheFolder.appendingPathComponent(name)
                
                var imageData: Data?
                
                if let image = imageinfo as? UIImage,
                    let data = image.jpegData(compressionQuality: 0.6) {
                    imageData = data
                }
                else if let data = imageinfo as? Data {
                    imageData = data
                }
                else if let url = imageinfo as? URL,
                    url.isFileURL{
                    imageData = try Data(contentsOf: url, options: .alwaysMapped)
                }
                
                if let imageData = imageData {
                    try imageData.write(to: filePath)
                }
                completion?(filePath)
            }
        }
        catch {
            throw error
        }
    }
    
    /// Remove image from cache folder
    ///
    /// - Parameter name: image name
    /// - Throws: throw any error if occured
    func removeImage(_ name: String) throws {
        do {
            if let fileURLPath = try getCacheDirectorWithImagesFolder()?.appendingPathComponent(name) {
                try self.removeItem(at: fileURLPath)
            }
        }
        catch {
            throw error
        }
    }
    
    /// Remove all images.
    ///
    /// - Throws: throw any error if occured
    func clearCachedImages() throws {
        do {
            if let fileURLPath = try getCacheDirectorWithImagesFolder() {
                try self.removeItem(at: fileURLPath)
            }
        }
        catch {
            throw error
        }
    }
    
    /// Fetch image from cache if available
    ///
    /// - Parameter name: image name
    /// - Returns: UIImage object
    /// - Throws: throw any error if occured
    func getImage(_ name:String) throws -> UIImage? {
        
        do {
            if let directory = try getCacheDirectorWithImagesFolder()?.appendingPathComponent(name) {
                
                guard !self.fileExists(atPath: directory.path) else {
                    return nil
                }

                guard let image = UIImage(contentsOfFile: directory.path) else {
                    return nil
                }
                
                return image
            }
            else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    /// Total cached images in cache directory
    ///
    /// - Returns: number of cached images
    /// - Throws: throw any error if occured
    func totalCachedImages() throws -> Int? {
        do {
            if let cacheDirectory = try getCacheDirectorWithImagesFolder() {
                let contents = try self.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                
                return contents.count
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    /// All cached images local File urls
    ///
    /// - Returns: array of file urls
    /// - Throws: throw any error if occured
    func allCachedImageURLPaths() throws -> [URL]? {
        do {
            if let cacheDirectory = try getCacheDirectorWithImagesFolder() {
                let contents = try self.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                
                return contents
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
}
