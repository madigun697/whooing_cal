//
//  InitViewController.swift
//  WhooingCal
//
//  Created by Kail Madigun on 9/4/16.
//  Copyright © 2016 Kail Madigun. All rights reserved.
//

import UIKit

class InitViewController: UIViewController {
    
    // UI Variables
    @IBOutlet var whooingIcon: UIImageView!
    
    // Custom Variables
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    // Information about Application for OAuth
    let app_secret:String = "90089d77732972d00733e622bbac5e2641d98013"
    let app_id:String = "186"
    let urlStr:String = "https://whooing.com/app_auth/request_token"
    
    // Temporary Token value
    var tempToken:String = ""
    
    // Application's defaults variables
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Application Icon Size using contratins(By user's screen size)
        let constraintWidth = NSLayoutConstraint(item: whooingIcon, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenSize.width/3)
        let constraintHeight = NSLayoutConstraint(item: whooingIcon, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenSize.width/3)
        whooingIcon.addConstraints([constraintWidth, constraintHeight])
        
        if defaults.objectForKey("accessToken") == nil {
            getTempToken()
            while (tempToken == "") {}
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTempToken() {
        
    }
    
    
}

