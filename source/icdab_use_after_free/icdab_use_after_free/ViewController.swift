//
//  ViewController.swift
//  icdab_use_after_free
//
//  Created by Faisal Memon on 11/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class MyParentViewController: UIViewController {
    
    weak var view1: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view1 = UIView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.addSubview(view1!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

