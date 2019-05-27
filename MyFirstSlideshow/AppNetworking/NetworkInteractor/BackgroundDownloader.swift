//
//  BackgroundDownloader.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 27/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

final class BackgroundDownloader: NSObject, URLSessionDownloadDelegate {
    
    private var session: URLSession!
    
    // MARK:- Variables -
    
    static let shared = BackgroundDownloader()

    private let ongoingRequestsSerialQueue:DispatchQueue = DispatchQueue(label: "com.Yoti.ongoingRequestsSerialQueue")
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
    
    private override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.Yoti.backgroundDownloads")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    // MARK:- Class Helpers -
    
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

        if let url = downloadTask.originalRequest?.url,
            let delegate = ongoingRequests[url] {
            
            ongoingRequests.removeValue(forKey: url)
            delegate.didFinishTask(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        if error != nil,
            let url = task.originalRequest?.url,
            let delegate = ongoingRequests[url] {
            
            ongoingRequests.removeValue(forKey: url)
            
            delegate.didFinishWithError(session, task: task, didCompleteWithError: error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        if let delegate = ongoingRequests[url] {
            delegate.downloadProgress(session, downloadTask: downloadTask, downloadProgress: progress)
        }
    }
}

protocol BackgroundDownloaderDelegate {
    
    func didFinishTask(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    
    func downloadProgress(_ session: URLSession, downloadTask: URLSessionDownloadTask, downloadProgress progress: Float)
    
    func didFinishWithError(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}
