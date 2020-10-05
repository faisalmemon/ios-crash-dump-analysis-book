//
//  ViewController.swift
//  icdab_rosetta_thread
//
//  Created by Faisal Memon on 05/10/2020.
//  Copyright © 2020 Faisal Memon. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var currentEnvironmentLabelOutlet: NSTextField!
    
    @IBAction func startThreadsTestButtonAction(_ sender: NSButtonCell) {
        print("about to start threads test")
        DispatchQueue.global().async {
            start_threads()
        }
    }
    
    func updateEnvironmentLabel() {
        do {
            let translated = try RosettaHelper.processIsTranslated()
            currentEnvironmentLabelOutlet.stringValue = "Code is running \(translated ? "Translated" : "Native")"
        } catch RosettaHelper.SystemError.SysCtlError(let err) {
            currentEnvironmentLabelOutlet.stringValue = "Cannot determine translation status; error \(err)"
        } catch {
            currentEnvironmentLabelOutlet.stringValue = "Translation status unknown"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateEnvironmentLabel()
    }

}

