//
//  ViewController.swift
//  icdab_asl
//
//  Created by Faisal Memon on 23/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit
import os

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...20 {
            os_log("Simple Message %d", i)
        }
        let string = "Hello"
        print ("Bad cast \(string as! Int)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

