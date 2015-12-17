//
//  QRCodeReaderResult.swift
//  Pods
//
//  Created by philippe on 15/12/2015.
//
//

import Foundation

public class QRCodeReaderResult: NSObject{
    public let value: String?
    public let type: String?
    
    init(value: String?, type: String?) {
        self.value = value
        self.type = type
    }
}