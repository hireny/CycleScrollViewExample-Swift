//
//  HXWebImageManager.swift
//  CycleScrollViewExample
//
//  Created by HX on 16/8/11.
//  Copyright © 2016年 HX. All rights reserved.
//

import UIKit

class HXWebImageManager {
    
    let downloader : HXWebImageDownloader
    
    let cache : HXWebImageCache
    
    class var sharedManager: HXWebImageManager {
        struct Static {
            static let instance = HXWebImageManager()
        }
        return Static.instance
    }
    
    init() {
        downloader = HXWebImageDownloader.shardedManager
        cache = HXWebImageCache.sharedManager
    }
    
    func downloadWithURL(url: NSURL, completionHandler: CompletionHandler) {
        
        retrieveImageWithURL(url, completionHandler: completionHandler)
    }
    
    func retrieveImageWithURL(url: NSURL, completionHandler: CompletionHandler) {
        
        if let image = cache.queryImageWithKey(url.absoluteString) {
            completionHandler(image: image, error: nil, imageURL: url)

        } else {
            downloader.downloadWithURL(url, completionHandler: { (image, error, imageURL) in
                completionHandler(image: image, error: error, imageURL: imageURL)
                self.cache.storeImageWithImage(image!, originalData: nil, forKey: url.absoluteString, toDisk: true, completionHandler: nil)
            })
        }
    }
}
