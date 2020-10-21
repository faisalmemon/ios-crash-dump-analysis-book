//
//  ViewController.swift
//  icdab_diag
//
//  Created by Faisal Memon on 20/10/2020.
//

import UIKit
import MetricKit

class ViewController: UIViewController {

    let memory = Memory()
    let metrics = MXMetricManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metrics.add(self)
        for item in metrics.pastDiagnosticPayloads {
            print(item)
        }
        for item in metrics.pastPayloads {
            print(item)
        }
    }

    @IBAction func dereferenceBadPointerButtonAction(_ sender: UIButton) {
        memory.dereferenceBadPointer()
    }
    
}

extension ViewController: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            print(payload)
        }
    }
    
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            print(payload)
        }
    }
}

