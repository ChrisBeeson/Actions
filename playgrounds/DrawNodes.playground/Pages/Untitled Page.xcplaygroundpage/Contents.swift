//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground

public class ActionNodeView: NSView {
    
    var text = "Wash Cells"
    var textField:NSTextField?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        updateView()
    }

    
    func updateView() {
        
        if textField == nil {
            textField = NSTextField(frame: NSRect(x: 10.0, y: self.frame.height - 40.0 , width: self.frame.width * 0.80, height: 25.0))
            textField!.font = NSFont.boldSystemFontOfSize(20.0)
            self.addSubview(textField!)
            textField?.bordered = false
        }
        
        textField!.stringValue = text
    }

    override func drawRect(dirtyRect: NSRect) {
        let tailOff:CGFloat = 0.85   // 85% of the view consists of the triangle
        let padding:CGFloat = 1.0
        let frame = self.frame
        
        NSColor.whiteColor().setFill()
        NSRectFill(self.bounds)
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: frame.size.width * tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width * tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - padding , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width * tailOff , y: frame.size.height - padding))
        
        NSColor.darkGrayColor().setStroke()
        path.lineWidth = 2.0
        path.lineJoinStyle = .MiterLineJoinStyle
        path.stroke()
    }
}

var view = CustomView(frame: NSRect(x: 0, y: 0, width: 300, height: 80))
