import UIKit
import QuartzCore

class Knob: UIControl {
    
    var value : CGFloat = 0.0 {
        didSet {
            if value < minValue {
                value = minValue
            }
            if value > maxValue {
                value = maxValue
            }
            redrawLayers()
        }
    }
    
    var knobLayer1 : KnobLayer! = nil
    
    var minAngle : CGFloat = 0.0 /*{
        didSet { redrawLayers() }
    }*/
    var maxAngle : CGFloat = 2*3.1415926 {
        didSet { redrawLayers() }
    }
    var minValue : CGFloat = 0.0 {
        didSet { redrawLayers() }
    }
    var maxValue : CGFloat = 1.0 {
        didSet { redrawLayers() }
    }
    
    var knobWidth : CGFloat = 200.0
    
    var previousTouchPoint : CGPoint = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        knobLayer1 = KnobLayer()
        knobLayer1.slider = self
        self.layer.addSublayer(knobLayer1)
        
        self.setLayerFrames()
    }
    
    func setLayerFrames() -> Void {
        knobWidth = bounds.size.height
        
        knobLayer1.frame = CGRectMake(0, 0, knobWidth, knobWidth)
        
        knobLayer1.setNeedsDisplay()
    }

    func angleForValue(value : CGFloat) -> CGFloat {
        return (value-minValue)/(maxValue-minValue)*(maxAngle-minAngle)+minAngle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        knobLayer1 = KnobLayer()
        knobLayer1.slider = self
        self.layer.addSublayer(knobLayer1)
        
        self.setLayerFrames()
    }
    
    override func beginTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        previousTouchPoint = touch.locationInView(self)
        
        // hit test the knob layers
        if CGRectContainsPoint(knobLayer1.frame, previousTouchPoint) {
            knobLayer1.highlighted = true
            knobLayer1.setNeedsDisplay()
        }
        return knobLayer1.highlighted
    }
    
    override func continueTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        let touchPoint = touch.locationInView(self)
    
        let delta = touchPoint.x-previousTouchPoint.x
        let valueDelta = 0.002*delta*(maxValue-minValue)
        value += valueDelta
        
        previousTouchPoint = touchPoint
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        setLayerFrames()
        CATransaction.setAnimationDuration(0.0)
        CATransaction.commit()
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch : UITouch?, withEvent event: UIEvent?) -> Void {
        knobLayer1.highlighted = false
        knobLayer1.setNeedsDisplay()
    }
    
    func redrawLayers() -> Void {
        knobLayer1.setNeedsDisplay()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
