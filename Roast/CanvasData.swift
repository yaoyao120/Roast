//
//  Canvas.swift
//  Roast
//
//  Created by Xiang Li on 2017-01-23.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import Foundation

class CanvasData: NSObject {
    
    var canvasType: CanvasType!
    
    var imageData: Data?
    
    var richText: NSAttributedString?
    
    //Image cell
    init(withCanvasType canvasType: CanvasType, imageData: Data) {
        super.init()
        
        self.canvasType = canvasType
        self.imageData = imageData
    }
    
    //text cell
    init(withCanvasType canvasType: CanvasType, textContent: NSAttributedString) {
        super.init()
        
        self.canvasType = canvasType
        self.richText = textContent
    }
    
    //Header cell
    init(withCanvasType canvasType: CanvasType, imageData: Data, textContent: NSAttributedString) {
        super.init()
        
        self.canvasType = canvasType
        self.imageData = imageData
        self.richText = textContent
        
    }
    
    //Add cell cell
    init(withCanvasType canvasType: CanvasType) {
        super.init()
        
        self.canvasType = canvasType
    }
    
    
}
