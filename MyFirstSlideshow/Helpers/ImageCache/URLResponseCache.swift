//
//  URLResponseCache.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation


/// We are taking it struct for now. So that later on we can modifty it to hold response keys and
/// can communicate with UserDefault for Encoding and Decoding itself.
struct URLResponseCache {

    func saveCachedHeaders(forKey key: String, headers: [String:Any]) {
       
        var fields: [String: Any]?
        if let obj = headers[RequestHeaders.Expires.rawValue] {
            if let components = Date().dateComponents(toDate: obj, dateFormat: Constant.expireDateFormat.rawValue),
                let year = components.year, year < 1,
                let month = components.month, month < 1,
                let day = components.day, day < 1,
                let hour = components.hour, hour < 1{
                
                fields = [String:Any]()
            }
            fields?[RequestHeaders.Expires.rawValue] = obj
        }
        if let obj = headers[RequestHeaders.CacheControl.rawValue] {
            fields?[RequestHeaders.CacheControl.rawValue] = obj
        }
        if let obj = headers[RequestHeaders.Etag.rawValue] {
            fields?[RequestHeaders.Etag.rawValue] = obj
        }
        if let fields = fields,
            !key.isEmpty{
            
            let defaults = UserDefaults.standard
            defaults.set(fields, forKey: key)
            defaults.synchronize()
        }
    }
    
    func isResponseCacheExpired(forKey key: String) -> Bool {

        if var headers = UserDefaults.standard.value(forKey: key) as? [String: Any],
            let obj = headers[RequestHeaders.Expires.rawValue],
            let components = Date().dateComponents(toDate: obj, dateFormat: Constant.expireDateFormat.rawValue),
            let year = components.year, year < 1,
            let month = components.month, month < 1,
            let day = components.day, day < 1,
            let hour = components.hour, hour < 1,
            let minute = components.minute, minute < 1{
            
            return true
        }
        return false
    }
    
    func cachedUrlResponse(forKey key: String) -> [String: Any]? {
        
        if !key.isEmpty,
            let savedHeaders = UserDefaults.standard.value(forKey: key) as? [String: Any] {
            return savedHeaders
        }
        return nil
    }
}

enum RequestHeaders: String {
    case CacheControl = "Cache-Control"
    case Etag
    case Expires = "Expires"
}
