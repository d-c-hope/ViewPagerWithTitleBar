//
//  WebViewController.swift
//  ViewPagerWithTitleBar
//
//  Created by David Hope on 24/07/2016.
//  Copyright © 2016 David Hope. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    var name: String = ""
    var url: String = ""
    
    //var currentOffset: CGFloat
    
    private var webView: WKWebView?
    
//    override func loadView() {
//        webView = WKWebView()
//
//        //If you want to implement the delegate
//        //webView?.navigationDelegate = self
//
//        view = webView
//        //webView?.navigationDelegate =
//    }
    
    var contentOffsetCallback: ((contentOffset: CGFloat, scrollView: UIScrollView) -> Void)?
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        //print("webview scrolling \(scrollView.contentOffset)")
        contentOffsetCallback?(contentOffset: contentOffset.y, scrollView: scrollView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.translatesAutoresizingMaskIntoConstraints = false
        
        webView = WKWebView()
        webView!.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = webView!.scrollView
        scrollView.delegate = self
        
        //webView!.frame = CGRect(x:20, y:20, width:200, height:200)
        webView!.navigationDelegate = self;
        self.view.addSubview(webView!)

        var allConstraints = [NSLayoutConstraint]()
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[view]|",
                options: [],
                metrics: nil,
                views: ["view" : webView!])
        allConstraints += verticalConstraints

        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[view]|",
                options: [],
                metrics: nil,
                views: ["view" : webView!])
        allConstraints += horizontalConstraints


        
        NSLayoutConstraint.activateConstraints(allConstraints)




        if let url = NSURL(string: "http://bbc.co.uk") {
            let req = NSURLRequest(URL: url)
            webView?.loadRequest(req)
        }
    }
    

}
