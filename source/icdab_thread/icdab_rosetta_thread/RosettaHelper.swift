//
//  RosettaHelper.swift
//  icdab_rosetta_thread
//
//  Created by Faisal Memon on 05/10/2020.
//  Copyright © 2020 Faisal Memon. All rights reserved.
//

import Foundation

class RosettaHelper {
    
    enum SystemError: Error {
        case SysCtlError(error: Int32)
    }
    
    static func processIsTranslated() throws -> Bool {
        let returnValuePointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let pointerToSizeOfInt = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        defer {
            returnValuePointer.deinitialize(count: 1)
            returnValuePointer.deallocate()
            pointerToSizeOfInt.deinitialize(count: 1)
            pointerToSizeOfInt.deallocate()
          }
        returnValuePointer.initialize(to: 0)
        pointerToSizeOfInt.initialize(to: MemoryLayout<Int>.size)
        if sysctlbyname("sysctl.proc_translated".cString(using: .ascii),
                        returnValuePointer,
                        pointerToSizeOfInt, nil, 0) == -1 {
            if (errno == ENOENT) {
                return false
            } else {
                throw SystemError.SysCtlError(error: errno)
            }
        }
        let result = returnValuePointer.pointee
        return result != 0
    }
}
