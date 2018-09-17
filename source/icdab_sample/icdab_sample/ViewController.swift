//
//  ViewController.swift
//  icdab_sample
//
//  Created by Faisal Memon on 10/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func takePhotoButtonAction(_ sender: Any) {
        takeCameraPhoto()
    }
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    @IBOutlet weak var macAddressLabelOutlet: UILabel!
    
    func takeCameraPhoto() {
        if UIImagePickerController
            .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            // Use Xcode 9.4.1 to see it enter here
            // Xcode 10.0 will skip over
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
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

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewOutlet.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}

