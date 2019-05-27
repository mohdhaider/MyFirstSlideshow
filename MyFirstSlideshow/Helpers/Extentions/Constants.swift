//
//  Constants.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

// App constants
enum Constant: String {
    case expireDateFormat = "E, d MMM yyyy HH:mm:ss ZZZ"
}

enum AppIntegerConstants: Int {
    case maxCacheCapicity = 10000
}

enum QueueLabels: String {
    case lruCacheQueue = "com.Yoti.lruCacheQueue"
    case ongoingBackgroundDownloadRequests = "com.Yoti.ongoingBackgroundDownloadRequests"
    case imageDownloading = "com.Yoti.imageDownloading"
    case dictCached = "com.Yoti.dictCached"
    case doublyLinkedList = "com.Yoti.doublyLinkedList"
    case imagesSerialQueue = "com.Yoti.imagesSerialQueue"
}
