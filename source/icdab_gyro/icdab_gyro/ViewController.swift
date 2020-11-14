//
//  ViewController.swift
//  icdab_gyro
//
//  Created by Faisal Memon on 14/11/2020.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    var motion = CMMotionManager()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGyros()
    }

    func startGyros() {
       if motion.isGyroAvailable {
          self.motion.gyroUpdateInterval = 1.0 / 60.0
          self.motion.startGyroUpdates()

          // Configure a timer to fetch the accelerometer data.
          self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                 repeats: true, block: { (timer) in
             // Get the gyro data.
             if let data = self.motion.gyroData {
                let x = data.rotationRate.x
                let y = data.rotationRate.y
                let z = data.rotationRate.z

                print("xyz is \(x) \(y) \(z)")
             }
          })

          // Add the timer to the current run loop.
        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
       }
    }

    func stopGyros() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil

          self.motion.stopGyroUpdates()
       }
    }
}

