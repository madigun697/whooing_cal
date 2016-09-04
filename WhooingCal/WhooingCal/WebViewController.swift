//
//  WebViewController.swift
//  WhooingCal
//
//  Created by Kail Madigun on 9/4/16.
//  Copyright © 2016 Kail Madigun. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    // UI Variables
    @IBOutlet var webView: UIWebView!
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    // Temporary Token value
    var tempToken:String = ""
    var pin:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Application Icon Size using contratins(By user's screen size)
        let constraintHeight = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenSize.height - 20)
        webView.addConstraint(constraintHeight)
        
        var authUrlStr:String! = "https://whooing.com/app_auth/authorize?token="
        authUrlStr = authUrlStr + tempToken
        webView.loadRequest(NSURLRequest(URL: NSURL(string: authUrlStr)!))
        webView?.delegate = self
    }
    
    // When web page loading is finished
    func webViewDidFinishLoad(webView: UIWebView) {
        // Current URL
        let curl = webView.request?.URL?.absoluteString
        
        // When ampersand is contained url, you have to find pin number through parsing url.
        let flag:Bool! = curl?.containsString("&")
        if (flag == true) {
            let parseUrl = curl?.componentsSeparatedByString("&")[1]
            let pinParam = parseUrl?.componentsSeparatedByString("=")
            
            if (pinParam![0] == "pin") {
                pin = pinParam![1]
                self.performSegueWithIdentifier("unwindFromWeb", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! InitViewController
        destination.pin = pin
    }
    
}