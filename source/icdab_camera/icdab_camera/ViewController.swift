//
//  ViewController.swift
//  icdab_camera
//
//  Created by Faisal Memon on 03/10/2020.
//

import UIKit

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

