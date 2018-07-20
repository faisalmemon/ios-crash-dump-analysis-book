//
//  PlanetViewController.swift
//  icdab_mem
//
//  Created by Faisal Memon on 19/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class PlanetViewController: UIViewController {

    @IBOutlet weak var planetImageOutlet: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Artificial delay to simulate slow network
        let deadlineTime = DispatchTime.now() + .seconds(5)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.downloadPlanetImage()
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        planetImageOutlet = nil // BUG; should be planetImageOutlet.image = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func downloadPlanetImage() {
        let location = Bundle.main.infoDictionary!["PlutoUrl"] as! String
        let helper = DownloadHelper(urlString: location)
        helper.downloadDelegate = self
    }
}

extension PlanetViewController: DownloadDelegate {
    func imageDownloaded(_ image: UIImage) {
        self.planetImageOutlet.image = image
    }
    
    func downloadFailed(_ error: NSError) {
        self.planetImageOutlet.image = nil
    }
}
