//
//  CanvasDataSource.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-22.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation

class Canvas {
    
    var dataSource = [CanvasData]() {
        didSet {
            for i in 0..<dataSource.count {
                print("*** Row \(i) type: \(dataSource[i].canvasType)")
            }
        }
    }
    
    
}
