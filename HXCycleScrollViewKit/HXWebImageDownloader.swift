//
//  HXWebImageDownloader.swift
//  CycleScrollViewExample
//
//  Created by HX on 16/8/11.
//  Copyright © 2016年 HX. All rights reserved.
//  图片下载类

import UIKit

// block 下载进度块 
typealias CompletionHandler = ((image: UIImage?, error: NSError?, imageURL: NSURL?) -> ())

private let kCompletionHandler = "kCompletionHandler"
private let downloaderBarrierName = "ImageDownloader.Barrier"

class HXWebImageDownloader: NSObject {
    
    
    struct ImageFetchLoad {
        var callbacks = [String: CompletionHandler?]()
        var responseData = NSMutableData()
    }
    
    var fetchLoads = [NSURL: ImageFetchLoad]()
    
    let barrierQueue = dispatch_queue_create(downloaderBarrierName, DISPATCH_QUEUE_CONCURRENT) // 多线程创建
    
    // 创建单例
    class var shardedManager: HXWebImageDownloader {
        struct Static {
            static let instatnce = HXWebImageDownloader()
        }
        return Static.instatnce
    }
    
    func downloadWithURL(URL: NSURL, completionHandler: CompletionHandler?) -> () {
        setProcessBlock(completionHandler!, URL: URL) { (session, fetchLoad) in
            let request = NSURLRequest(URL: URL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 15)
            let task = session.dataTaskWithRequest(request)
            task.resume()  // 启动任务
        }
    }
    
    
    func setProcessBlock(completionHandler: CompletionHandler, URL: NSURL, started: ((NSURLSession, ImageFetchLoad) -> Void)) -> () {
        
        dispatch_barrier_sync(barrierQueue) { 
            var first = false
            if self.fetchLoads[URL] == nil {
                self.fetchLoads[URL] = ImageFetchLoad()
                first = true
            }
            
            var fetchURL = self.fetchLoads[URL]
            fetchURL?.callbacks[kCompletionHandler] = completionHandler
            
            self.fetchLoads[URL] = fetchURL
            
            if first {
                let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
                started(session, fetchURL!)
            }
        }
    }
    
    func cleanURL(URL: NSURL) -> () {
        dispatch_barrier_sync(barrierQueue) { 
            self.fetchLoads.removeValueForKey(URL)
        }
    }
}

extension HXWebImageDownloader: NSURLSessionDataDelegate {
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let url = dataTask.originalRequest!.URL, fetchLoad = fetchLoads[url] {
            fetchLoad.responseData.appendData(data)
            dispatch_async(dispatch_get_main_queue(), { 
                
            })
        }
    }
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let url = task.originalRequest?.URL
        if let error = error {
            callbackWithImage(nil, error: error, imageURL: url!)
        } else {
            
            dispatch_async(dispatch_queue_create("ImageProcessQueue", DISPATCH_QUEUE_CONCURRENT), { 
                if let fetchLoad = self.fetchLoads[url!] {
                    if let image = UIImage(data: fetchLoad.responseData) {
                        self.callbackWithImage(image, error: nil, imageURL: url!)
                    }
                    self.cleanURL(url!)
                }
            })
        }
        
    }
    
    func callbackWithImage(image: UIImage?, error: NSError?, imageURL: NSURL) -> () {
        if let completionHandler = self.fetchLoads[imageURL]?.callbacks[kCompletionHandler] {
            dispatch_async(dispatch_get_main_queue(), { 
                completionHandler!(image: image, error: error, imageURL: imageURL)
            })
        }
    }
}
