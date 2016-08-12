//
//  ThreadHelper.swift
//  CycleScrollViewExample
//
//  Created by HX on 16/8/12.
//  Copyright © 2016年 HX. All rights reserved.
//

import Foundation

func dispatch_async_safely_to_main_queue(block: () -> ()) {
    dispatch_async_safely_to_queue(dispatch_get_main_queue(), block)
}

// This method will dispatch the `block` to a specified `queue`.
// If the `queue` is the main queue, and current thread is main thread, the block
// will be invoked immediately instead of being dispatched.
func dispatch_async_safely_to_queue(queue: dispatch_queue_t, _ block: () -> ()) {
    if queue === dispatch_get_main_queue() && NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(queue, { 
            block()
        })
    }
}
