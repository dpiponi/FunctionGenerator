import UIKit
import QuartzCore

class KnobLayer: CALayer {
    var highlighted : Bool = false
    weak var slider : Knob! = nil
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        
        let path3 = NSBundle.mainBundle().pathForResource("knob3", ofType:"png")
        
        let dataProvider3 = CGDataProviderCreateWithFilename(path3!)
        let image3 = CGImageCreateWithPNGDataProvider(dataProvider3, nil, false, .RenderingIntentDefault)
        
        let path2 = NSBundle.mainBundle().pathForResource("knob2", ofType:"png")
        
        let dataProvider2 = CGDataProviderCreateWithFilename(path2!)
        let image2 = CGImageCreateWithPNGDataProvider(dataProvider2, nil, false, .RenderingIntentDefault)
        
        let path1 = NSBundle.mainBundle().pathForResource("knob1", ofType:"png")
        
        let dataProvider1 = CGDataProviderCreateWithFilename(path1!)
        let image1 = CGImageCreateWithPNGDataProvider(dataProvider1, nil, false, .RenderingIntentDefault)
        
        let knobFrame = CGRectInset(bounds, 2.0, 2.0)
        
        // 1) fill - with a subtle shadow
        let rect = CGRectInset(knobFrame, 2.0, 2.0)
        
        CGContextSaveGState(ctx);
        
        //
        // http://stackoverflow.com/questions/14404877/anti-aliasing-uiimage-looks-blurred-or-jagged
        //
//        CGContextSetShouldAntialias(ctx, true)
        CGContextSetInterpolationQuality(ctx, .High)
        
        CGContextDrawImage(ctx, rect, image3)
        CGContextTranslateCTM(ctx, bounds.width/2, bounds.height/2)
        CGContextRotateCTM(ctx, slider.angleForValue(slider.value))
        CGContextTranslateCTM(ctx, -bounds.width/2, -bounds.height/2)
        CGContextDrawImage(ctx, rect, image2)
        CGContextRestoreGState(ctx);
        CGContextDrawImage(ctx, rect, image1)
        
//        CGContextRestoreGState(ctx);
        
    }
}
    
