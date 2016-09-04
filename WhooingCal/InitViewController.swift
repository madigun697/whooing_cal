//
//  InitViewController.swift
//  WhooingCal
//
//  Created by Kail Madigun on 9/4/16.
//  Copyright © 2016 Kail Madigun. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func sha1() -> String {
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}

class InitViewController: UIViewController, Dimmable {
    
    // UI Variables
    @IBOutlet var loadingLable: UILabel!
    @IBOutlet var whooingIcon: UIImageView!
    
    // Custom Variables
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    
    // Information about Application for OAuth
    let appSecret:String = "90089d77732972d00733e622bbac5e2641d98013"
    let appId:String = "186"
    let urlStr:String = "https://whooing.com/app_auth/request_token"
    
    // Variables related Access Token
    var tempToken:String = ""
    var token:String = ""
    var tokenSecret:String = ""
    var userId:String = ""
    var xApiKey:String = ""
    var pin:String = ""
    
    var debugFlag = true
    
    // Application's defaults variables
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.defaults.removeObjectForKey("accessToken")
//        self.defaults.removeObjectForKey("tokenSecret")
//        self.defaults.removeObjectForKey("userId")
        
        
        // Setting Application Icon Size using contratins(By user's screen size)
        let constraintWidth = NSLayoutConstraint(item: whooingIcon, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenSize.width/3)
        let constraintHeight = NSLayoutConstraint(item: whooingIcon, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenSize.width/3)
        whooingIcon.addConstraints([constraintWidth, constraintHeight])
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Checking Access Token
        // If UserDefaults doesn't have Access Token, application tries to get Access Token
        if defaults.objectForKey("accessToken") == nil {
            getTempToken()
            while (tempToken == "") {}
            
            self.performSegueWithIdentifier("authSegue", sender: self)
           
        // If UserDefaults already has Access Token, application goes to next View
        } else {
                        goToMain()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTempToken() {
        
        do {
            let url = NSURL(string: "\(urlStr)?app_secret=\(appSecret)&app_id=\(appId)")
            let request = NSMutableURLRequest(URL: url!)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil {
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:String]
                    let t:String! = result!["token"]
                    self.tempToken = t
                    print("Result -> \(result)")
                    
                } catch {
                    print("Error -> \(error)")
                }
            }
            
            task.resume()
            
        }
        
    }
    
    func getAccessToken() {
        
        do {
            let url = NSURL(string: "https://whooing.com/app_auth/access_token?app_id=\(appId)&app_secret=\(appSecret)&token=\(tempToken)&pin=\(pin)")
            let request = NSMutableURLRequest(URL: url!)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil {
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:String]
                    self.token = result!["token"]!
                    self.tokenSecret = result!["token_secret"]!
                    self.userId = result!["user_id"]!
                    
                    print("Get Token() :: Token -> \(self.token), Token Secret -> \(self.tokenSecret), User Id -> \(self.userId)")
                    print("Result -> \(result)")
                    
                } catch {
                    print("Error -> \(error)")
                }
            }
            
            task.resume()
            
        }
        
    }
    
    // Making encrypting API Key value
    func makeXAPIKey() {
        var sha1:String = appSecret + "|" + tokenSecret
        sha1 = sha1.sha1()
        
        var nounce = NSUUID().UUIDString
        nounce = nounce.stringByReplacingOccurrencesOfString("-", withString: "")
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        while (token == "") {}
        
        xApiKey = "app_id=\(appId),token=\(token),signiture=\(sha1),nounce=\(nounce),timestamp=\(timestamp)"
        
        defaults.setObject(xApiKey, forKey: "xApiKey")

    }
    
    // Moving Main View Controller
    func goToMain() {
        loadingLable.text = "Sign In Complete"
        
        // Delay time
        let triggerTime = (Int64(NSEC_PER_SEC) * 2)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.performSegueWithIdentifier("goToMain", sender: self)
        })
        
        
    }
    
    // Before move to webAuthVC, transfer temporary token
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Branch where to go
        if (segue.identifier == "authSegue") {
            
            // When application call WebViewController, Transfer temporary token
            let destination = segue.destinationViewController as! WebViewController
            destination.tempToken = tempToken
            
            dim(.In, alpha: dimLevel, speed: dimSpeed)
        } else if (segue.identifier == "goToMain") {
            let destination = segue.destinationViewController as! MainViewController
            destination.appId = appId
            destination.appSecret = appSecret
            destination.xApiKey = xApiKey
        }
    }
    
    // When webAuthVC unwind, Request access token w/ temporary token and pin number
    @IBAction func unwindFromWeb(segue: UIStoryboardSegue) {       
        
        getAccessToken()
        while(token == "") {}
        
        defaults.setObject(token, forKey: "accessToken")
        defaults.setObject(tokenSecret, forKey: "tokenSecret")
        defaults.setObject(userId, forKey: "userId")
        
        makeXAPIKey()
        while(xApiKey == "") {}
        
        dim(.Out, speed: dimSpeed)
        
        goToMain()
        
    }
    
}

