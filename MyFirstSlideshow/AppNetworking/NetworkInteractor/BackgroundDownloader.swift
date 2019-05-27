//
//  BackgroundDownloader.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 27/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

/// URLSession background tasks downloder manager.
final class BackgroundDownloader: NSObject, URLSessionDownloadDelegate {
    
    private var session: URLSession!
    
    // MARK:- Variables -
    
    static let shared = BackgroundDownloader()

    /// We can submit download requets in concurrent manner as much as we want but we do need to tarck and update their
    /// state to "ongoingRequests" holder in thread safe manner. For that we can currently use serial queue to
    /// achive thread safety.
    private let ongoingRequestsSerialQueue:DispatchQueue = DispatchQueue(label: QueueLabels.ongoingBackgroundDownloadRequests.rawValue)
    private var tempOngoingRequests = [URL: BackgroundDownloaderDelegate]()
    private var ongoingRequests: [URL: BackgroundDownloaderDelegate] {
        get {
            return ongoingRequestsSerialQueue.sync { tempOngoingRequests }
        }
        set {
            ongoingRequestsSerialQueue.async {[weak self] in self?.tempOngoingRequests = newValue }
        }
    }
    
    // MARK:- Initializers -
    
    /// Setting up background session configuration.
    private override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.Yoti.backgroundDownloads")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    // MARK:- Class Helpers -
    
    /// Check whether a save download task in in progress or not. If not then will
    /// create a download task and provided to caller.
    /// - Parameters:
    ///   - request: URLRequest object
    ///   - delegate: Background downloading tasks callback delegate object
    /// - Returns: URLSessionDownloadTask object nullable
    func getDownloadTask(forRequest request: URLRequest, delegate: BackgroundDownloaderDelegate) -> URLSessionDownloadTask? {
        
        if let url = request.url,
            let _ = ongoingRequests[url] {
            return nil
        } else if let url = request.url {
            ongoingRequests[url] = delegate
            return session.downloadTask(with: request)
        }
        
        return nil
    }
    
    // MARK:- URLSessionDownloadDelegate -
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        /// If finished task in it ongoingRequests, then removing it and providing required information
        /// to caller delegate.
        if let url = downloadTask.originalRequest?.url,
            let delegate = ongoingRequests[url] {
            
            ongoingRequests.removeValue(forKey: url)
            delegate.didFinishTask(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        /// If error task in it ongoingRequests, then removing it and providing required information
        /// to caller delegate.
        if error != nil,
            let url = task.originalRequest?.url,
            let delegate = ongoingRequests[url] {
            
            ongoingRequests.removeValue(forKey: url)
            
            delegate.didFinishWithError(session, task: task, didCompleteWithError: error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url else { return }
        
        /// If task in it ongoingRequests, then calculating download progress and providing it
        /// to caller delegate.
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        if let delegate = ongoingRequests[url] {
            delegate.downloadProgress(session, downloadTask: downloadTask, downloadProgress: progress)
        }
    }
}

/// Background downloading tasks delegate methods. You can adopt these methods to get downloading tasks state changes.
protocol BackgroundDownloaderDelegate {
    
    func didFinishTask(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    
    func downloadProgress(_ session: URLSession, downloadTask: URLSessionDownloadTask, downloadProgress progress: Float)
    
    func didFinishWithError(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}
