//
//  DownloadHelper.swift
//  icdab_mem
//
//  Created by Faisal Memon on 19/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import Foundation
import UIKit.UIImage

protocol DownloadDelegate {
    func imageDownloaded(_ image: UIImage)
    func downloadFailed(_ error: NSError)
}

class DownloadHelper {
    var downloadDelegate: DownloadDelegate?
    
    static let noSuchUrlError = NSError(domain: "Downloader",
                                        code: Int(ENOENT),
                                        userInfo: nil)
    static let cannotCreateImageFromData = NSError(domain: "Downloader",
                                                   code: Int(EINVAL),
                                                   userInfo: nil)
    
    init(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.downloadDelegate?.downloadFailed(DownloadHelper.noSuchUrlError)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    self.downloadDelegate?.downloadFailed(error! as NSError)
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async() {
                    self.downloadDelegate?.downloadFailed(DownloadHelper.cannotCreateImageFromData)
                }
                return
            }
            
            DispatchQueue.main.async() {
                self.downloadDelegate?.imageDownloaded(image)
            }
        }
        
        task.resume()
    }
}
