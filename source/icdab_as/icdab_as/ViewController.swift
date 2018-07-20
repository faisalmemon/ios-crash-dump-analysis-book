//
//  ViewController.swift
//  icdab_as
//
//  Created by Faisal Memon on 20/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        switchToAssemblyCodePath()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func switchToAssemblyCodePath() {
        let result = scaffold(10, 40)
        print(result)
        let asResult = bad_instruction_egg(10, 40)
        print(asResult)
    }
}

