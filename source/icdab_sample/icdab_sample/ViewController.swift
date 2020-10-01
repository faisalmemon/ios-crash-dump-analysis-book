//
//  ViewController.swift
//  icdab_sample
//
//  Created by Faisal Memon on 10/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    @IBOutlet weak var macAddressLabelOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let macAddress = MacAddress()
        if let deviceMacAddress = macAddress.getMacAddress() {
            macAddressLabelOutlet.text = deviceMacAddress
        } else {
            macAddressLabelOutlet.text = "Unknown"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
