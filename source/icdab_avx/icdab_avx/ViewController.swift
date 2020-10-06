//
//  ViewController.swift
//  icdab_avx
//
//  Created by Faisal Memon on 06/10/2020.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var currentStatusLabelOutlet: NSTextField!
    
    @IBAction func runVectorOperationsButtonAction(_ sender: NSButtonCell) {
        compute_delta()
    }
    
    func updateStatusLabel() {
        if avx_v1_supported() {
            currentStatusLabelOutlet.stringValue = "AVX v1 supported"
        } else {
            currentStatusLabelOutlet.stringValue = "AVX v1 not supported"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateStatusLabel()
    }
}

