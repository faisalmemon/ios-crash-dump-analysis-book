//
//  ViewController.swift
//  icdab_edge
//
//  Created by Faisal Memon on 09/09/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    static let crash = Crash()
    
    @IBAction func crashCorruptMallocButtonPressed(_ sender: UIButton) {
        ViewController.crash.corruptMalloc()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

