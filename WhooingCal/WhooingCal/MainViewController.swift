//
//  MainViewController.swift
//  WhooingCal
//
//  Created by Kail Madigun on 9/4/16.
//  Copyright © 2016 Kail Madigun. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    var appSecret:String = ""
    var appId:String = ""
    var xApiKey:String = ""
    
    // Application's defaults variables
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("here")
    }
    
}
