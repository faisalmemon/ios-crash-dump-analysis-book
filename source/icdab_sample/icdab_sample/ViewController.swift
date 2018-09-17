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
            .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imageViewOutlet.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
