//
//  ViewController.swift
//  CycleScrollViewExample
//
//  Created by HX on 16/8/9.
//  Copyright © 2016年 HX. All rights reserved.
//

import UIKit
//HXCycleScrollViewKit/CycleScrollViewExample-Bridging-Header.h
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.createView()
    }
    
    func createView() {
        
        let cycleViewFrame = CGRectMake( 0, 64, CGRectGetWidth(self.view.frame), 200)
        let imageArray = ["http://b.hiphotos.baidu.com/zhidao/pic/item/d01373f082025aaf755f5631f9edab64024f1ade.jpg","http://e.hiphotos.baidu.com/zhidao/pic/item/95eef01f3a292df51caa0332bd315c6034a873a8.jpg","http://photocdn.sohu.com/20151124/mp43786429_1448294862260_4.jpeg",NSURL(string: "http://image84.360doc.com/DownloadImg/2015/04/0109/51858656_3.jpg")!]
        let cycleView = HXCycleScrollView.init(frame: cycleViewFrame, imagesArray: imageArray)
        self.view.addSubview(cycleView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

