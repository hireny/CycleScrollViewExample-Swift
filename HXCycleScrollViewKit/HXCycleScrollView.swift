//
//  HXCycleScrollView.swift
//  CycleScrollViewExample
//
//  Created by HX on 16/8/9.
//  Copyright © 2016年 HX. All rights reserved.
//

import UIKit

class HXCycleScrollView: UIView ,UIScrollViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // 滚动视图
    var scrollView : UIScrollView?
    // 页面控制
    var pageControl : UIPageControl?
    // 要展示的图片的数组
    var imagesArray : [AnyObject]?
    // 定时器 时间间隔
    var timeInterval : NSTimeInterval = 1
    
    
    // 当前显示的图片
    var currentImageView : UIImageView?
    // 左右滑动显示的图片
    var otherImageView : UIImageView?
    // 当前图片的索引
    var currentIndex = NSInteger()
    // 下一张图片的索引
    var nextPageIndex = NSInteger()
    // 定时器
    private var timer : NSTimer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // 移除定时器
        if timer != nil {
            timer?.invalidate()
        }
    }
    
    /**
     自定义初始化方法
     */
    init(frame: CGRect, imagesArray: [AnyObject]) {
        super.init(frame: frame)
        self.imagesArray = imagesArray
        self.autoresizesSubviews = true
        self.currentIndex = 0
        self.initTimer()
        self.initCycleScrollView()
    }
    /**
     初始化定时器
     */
    func initTimer() -> () {
        if self.imagesArray?.count <= 1 {
            return
        }
        if timer != nil {
            timer?.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: #selector(HXCycleScrollView.timerFunction), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
    }
    /**
     定时器调用的方法
     */
    func timerFunction() -> () {
        // 动画改变 scrollView 的偏移量就可以实现自动滚动
        self.scrollView?.setContentOffset(CGPointMake(CGRectGetWidth(self.scrollView!.frame) * 2, 0), animated: true)
    }
    func initCycleScrollView() -> () {
        
        if self.scrollView == nil {
            self.scrollView = UIScrollView.init(frame: self.bounds)
            self.scrollView?.delegate = self
            self.addSubview(self.scrollView!)
            
            self.scrollView?.contentMode = .Center
            self.scrollView?.pagingEnabled = true
            self.scrollView?.scrollEnabled = true  // 启用滚动
            self.scrollView?.scrollsToTop = false
            self.scrollView?.bounces = true    // 反弹效果
            self.scrollView?.showsHorizontalScrollIndicator = false
            self.scrollView?.showsVerticalScrollIndicator = false
            
            // 两张图片的初始化
            self.otherImageView = UIImageView.init()
            self.otherImageView?.frame = self.bounds
            self.otherImageView!.userInteractionEnabled = true
            self.otherImageView?.contentMode = .ScaleToFill
            self.scrollView?.addSubview(self.otherImageView!)
            
            self.currentImageView = UIImageView.init()
            self.currentImageView?.frame = CGRectMake(CGRectGetWidth(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
            self.currentImageView!.userInteractionEnabled = true
            self.currentImageView?.contentMode = .ScaleToFill
            self.scrollView?.addSubview(currentImageView!)
        }
        self.scrollView?.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView!.frame) * 3, CGRectGetHeight(self.scrollView!.frame))
        self.scrollView?.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView!.frame), 0)
        // 设置当前图片
        self.loadImage(self.currentImageView!, index: self.currentIndex)
        
        // 添加 UIPageControl
        self.scrollPage(self.imagesArray!.count)
    }
    // UIPageControl
    func scrollPage(maxNumber: Int) {
        self.pageControl = UIPageControl.init()
        self.pageControl?.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 50, CGRectGetWidth(self.frame), 50)
        self.pageControl!.numberOfPages = NSInteger(maxNumber)
        self.pageControl!.currentPage = currentIndex
        self.pageControl!.userInteractionEnabled = false
        self.pageControl!.currentPageIndicatorTintColor = UIColor.redColor()
        self.pageControl!.alpha = 1.0
        self.addSubview(self.pageControl!)
    }
    // 更新图片
    func changeToNextPage() -> () {
        self.currentIndex = self.nextPageIndex
        self.pageControl?.currentPage = self.currentIndex
        self.currentImageView!.image = self.otherImageView!.image
        self.scrollView?.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView!.frame), 0)
    }
    // 加载
    func loadImage(imageView: UIImageView, index:Int) {
        let imageData = self.imagesArray![index];

        if imageData is String {
            let url: NSURL = NSURL(string:(imageData as? String)!)!
            imageView.hx_setImageWithURL(url)
        } else if imageData is NSURL {
            let url: NSURL = (imageData as? NSURL)!
            imageView.hx_setImageWithURL(url)
        }
    }
    
    // MARK : UIScrollView Delegate
    // 开始拖动时停止自动轮播
    internal func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.timer?.invalidate()
    }
    // 停止拖动时恢复自动轮播
    internal func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.initTimer()
    }
    
    // UIScrollView 滑动时 调用
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        if contentOffsetX > CGRectGetWidth(scrollView.frame) {
            // 左滑
            
            // 将其他图片显示在右边
            self.otherImageView?.frame = CGRectMake(CGRectGetMaxX(self.currentImageView!.frame), 0, CGRectGetWidth(self.otherImageView!.frame), CGRectGetHeight(self.otherImageView!.frame))
            
            self.nextPageIndex = self.currentIndex + 1
            if self.nextPageIndex > self.imagesArray!.count - 1 {
                self.nextPageIndex = 0
            }
            
            
            if contentOffsetX >= CGRectGetWidth(scrollView.frame) * 2 {
                self.changeToNextPage()
            }
        } else if contentOffsetX < CGRectGetWidth(scrollView.frame) {
            // 右滑
            
            // 将其他图片显示左边
            self.otherImageView?.frame = CGRectMake(0, 0, CGRectGetWidth(self.otherImageView!.frame), CGRectGetHeight(self.otherImageView!.frame))
            
            self.nextPageIndex = self.currentIndex - 1
            if self.nextPageIndex < 0 {
                self.nextPageIndex = self.imagesArray!.count - 1
            }
            
            if contentOffsetX <= 0 {
                self.changeToNextPage()
            }
        }
        // 加载
        self.loadImage(self.otherImageView!, index: self.nextPageIndex)
    }
}
