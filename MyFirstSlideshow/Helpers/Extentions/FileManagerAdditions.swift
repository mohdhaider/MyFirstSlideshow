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
    
    func getCacheDirectorWithImagesFolder() throws -> URL? {
        
        do {
            let cachedDirectory = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("CachedImages")
            
            if !self.fileExists(atPath: cachedDirectory.absoluteString) {
                try self.createDirectory(at: cachedDirectory, withIntermediateDirectories: false, attributes: nil)
            }
            
            return cachedDirectory
        }
        catch {
            throw FileManagerErrors.CacheDirectoryFolderNotCreated
        }
    }
    
    func saveImage(_ imageinfo: Any, imageName name: String, _ completion:((_ imagePath: URL?) -> ())?) throws {

        do {
            if let cacheFolder = try getCacheDirectorWithImagesFolder() {
                
                let filePath = cacheFolder.appendingPathComponent(name)
                
                var imageData: Data?
                
                if let image = imageinfo as? UIImage,
                    let data = image.pngData() {
                    imageData = data
                }
                else if let data = imageinfo as? Data {
                    imageData = data
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
    
    func getImage(_ name:String) throws -> UIImage? {
        
        do {
            if let directory = try getCacheDirectorWithImagesFolder()?.appendingPathComponent(name) {
                
                guard !self.fileExists(atPath: directory.absoluteString) else {
                    return nil
                }

                guard let image = UIImage(contentsOfFile: directory.absoluteString) else {
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
