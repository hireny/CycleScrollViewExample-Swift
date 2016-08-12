//
//  HXWebImageCache.swift
//  CycleScrollViewExample
//
//  Created by HX on 16/8/11.
//  Copyright © 2016年 HX. All rights reserved.
//  缓存

import UIKit

private let cacheName = "Default"

class HXWebImageCache {
    
    class var sharedManager: HXWebImageCache {
        struct Static {
            static let instance = HXWebImageCache(cacheName: cacheName)
        }
        return Static.instance
    }
    
    var memoryCache = NSCache() // 内存缓存
    
    private let ioQueue = dispatch_queue_create("HXWebImageCacheIOQueue", DISPATCH_QUEUE_SERIAL) // 生成一个串行队列，队列中的block按照先进先出（FIFO）的顺序去执行，实际上为单线程执行。第一个参数是队列的名称，在调试程序时会非常有用，所以尽量不要重名
    
    // 硬盘缓存地址
    var diskCachePath : String = ""
    
    
    init(cacheName: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) // 获取沙盒 Cache路径
        self.diskCachePath = (paths.first! as NSString).stringByAppendingPathComponent(cacheName)  // stringByAppendingPathComponent(str: String) 添加/符号，使之成为完整的路径
        print("缓存地址: \(self.diskCachePath)")
    }
    
//    func storeImageWithImage(image: UIImage, key: String, toDisk: Bool = true, completionHandler: (()-> Void)? = nil) {
//        storeImageWithImage(image, key: key, toDisk: toDisk, completionHandler: completionHandler)
//    }
    
    func storeImageWithImage(image: UIImage, originalData: NSData?, forKey key: String, toDisk: Bool = true, completionHandler: (() -> Void)? = nil) {
        self.memoryCache.setObject(image, forKey: key)
        
        // 调用处理程序
        func callHandlerInMainQueue() {
            if let handler = completionHandler {
                // 回主线程
                dispatch_async(dispatch_get_main_queue()) {
                    handler()
                }
            }
        }
        
        if toDisk {
            
            dispatch_async(self.ioQueue, {
                if let data = UIImageJPEGRepresentation(image, 1.0) {
                    let fileManager = NSFileManager()
                    if !fileManager.fileExistsAtPath(self.diskCachePath) {
                        // 创建目录
                        do {
                            try fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                        } catch _ {}
                    }
                    // 创建文件
                    fileManager.createFileAtPath(self.diskCachePath + key.kf_MD5, contents: data, attributes: nil)
                }
                callHandlerInMainQueue()
            })
        } else {
            callHandlerInMainQueue()
        }
    }
    
    // 删除图像
    func removeImageForKey(key: String, fromDisk: Bool = true, completionHandler: (() -> Void)? = nil) {
        
        self.memoryCache.removeObjectForKey(key)
        
        // 调用处理程序
        func callHandlerInMainQueue() {
            if let handler = completionHandler {
                // 回主线程
                dispatch_async(dispatch_get_main_queue()) {
                    handler()
                }
            }
        }
        
        if fromDisk {
            dispatch_async(self.ioQueue) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(self.diskCachePath + key.kf_MD5)
                } catch _ {}
                callHandlerInMainQueue()
            }
        } else {
            callHandlerInMainQueue()
        }
    }
    
    // 查询图像
    func queryImageWithKey(key: String) -> UIImage? {
        if let image = self.memoryCache.objectForKey(key) {
            return image as? UIImage
        } else {
            // 根据路径读取某个文件
            if let image = NSFileManager.defaultManager().contentsAtPath(self.diskCachePath + key.kf_MD5) {
                return UIImage(data: image)!
            } else {
                return nil
            }
        }
    }
}