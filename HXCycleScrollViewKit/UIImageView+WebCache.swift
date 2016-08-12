//
//  UIImageView+WebCache.swift
//  CycleScrollViewExample
//
//  Created by HX on 16/8/11.
//  Copyright © 2016年 HX. All rights reserved.
//

import UIKit

extension UIImageView {
    
    
    public func hx_setImageWithURL(URL: NSURL) {
        hx_setImageWithURL(URL, placeHolderImage: nil)
    }
    
    public func hx_setImageWithURL(URL: NSURL, placeHolderImage: UIImage?) {
        
        self.hx_setImageURL(URL) // 把图片的服务器地址绑定到运行时
        
        image = placeHolderImage
        
        HXWebImageManager.sharedManager.downloadWithURL(URL) { [weak self](image, error, imageURL) in
            
            dispatch_async_safely_to_main_queue({ 
                if imageURL == URL && image != nil {
                    self!.image = image
                }
            })
        }
    }
}


private var lastURLKey: Void
public extension UIImageView {
    
    public var hx_getImageURL: NSURL? {
        return objc_getAssociatedObject(self, &lastURLKey) as? NSURL
    }
    
    private func hx_setImageURL(URL: NSURL) {
        
        objc_setAssociatedObject(self, &lastURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
