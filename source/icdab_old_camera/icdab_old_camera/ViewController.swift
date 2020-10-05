//
//  ViewController.swift
//  icdab_old_camera
//
//  Created by Faisal Memon on 05/10/2020.
//  Copyright © 2020 Faisal Memon. All rights reserved.
//

import UIKit

// This program is designed to be tested on iOS 11.x
// to confirm that the system will pass the isCameraDeviceAvailable
// check and result in a crash.

class ViewController: UIViewController, UINavigationControllerDelegate {
//    @IBAction func pickerButtonPressedAction(_ sender: Any) {

    @IBAction func pickerButtonPressed(_ sender: Any) {
        handlePickerButtonPressed()
    }
    
    func handlePickerButtonPressed() {
        if UIImagePickerController.isCameraDeviceAvailable(.front) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
}

