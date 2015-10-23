//
//  ViewController.swift
//  FunctionGenerator
//
//  Created by Dan Piponi on 10/20/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

//
// http://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html
//
func sampleShader(
    inRefCon : UnsafeMutablePointer<Void>,
    ioActionFlags : UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp : UnsafePointer<AudioTimeStamp>,
    inBusNumber : UInt32,
    inNumberFrames : UInt32,
    ioData : UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        let viewController = unsafeBitCast(inRefCon, ViewController.self)
        let buffer = UnsafeMutablePointer<Float>(ioData.memory.mBuffers.mData) // mBuffers[0]???
        
        let amplitude : Double = 0.3333
        
        for i in 0..<Int(inNumberFrames) {
            buffer[i] = Float(amplitude*sin(viewController.phase))
            
            viewController.phase += 2.0*M_PI*viewController.actualFrequency/viewController.sampleRate
            viewController.actualFrequency = 0.999*viewController.actualFrequency+0.001*viewController.frequency
            if (viewController.phase > 2.0 * M_PI) {
                viewController.phase -= 2.0 * M_PI
            }
        }
        
        return noErr;
}

//
// https://grokswift.com/custom-fonts/
//
class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyKnob: Knob!
    
    var gen : AudioComponentInstance = nil
    
    var frequency : Double = 440.0
    var actualFrequency = 440.0
    var sampleRate : Double = 44100.0
    var phase : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        if audioSession.otherAudioPlaying {
            do {
                try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
            } catch { print("Error1") }
        } else {
            do {
                try audioSession.setCategory(AVAudioSessionCategoryAmbient)
            } catch { print("Error2") }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleInterruption:",
            name: AVAudioSessionInterruptionNotification,
            object: nil)
        
        frequencyKnob.minValue = 200
        frequencyKnob.maxValue = 2000
        frequencyKnob.minAngle = 3.14159/8
        frequencyKnob.maxAngle = 2*3.14159-3.14159/8
        frequencyKnob.value = 200
        
        knobChanged(frequencyKnob)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //
    // Needs testing
    //
    func handleInterruption(player: AVAudioPlayer) {
        print("Hello")
        stop()
    }
    
    @IBAction func knobChanged(knob: Knob) {
        frequency = Double(knob.value)
        frequencyLabel.text = String(format:"%4.1f Hz", frequency)
    }
    func getAudioComponentDescription() -> AudioComponentDescription {
        return AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_RemoteIO,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        )
    }
    
    func getAudioStreamBasicDescription() -> AudioStreamBasicDescription {
        let sizeofFloat = UInt32(sizeof(Float))
        return AudioStreamBasicDescription(
                    mSampleRate: sampleRate,
                    mFormatID: kAudioFormatLinearPCM,
                    mFormatFlags: kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
                    mBytesPerPacket: sizeofFloat,
                    mFramesPerPacket: 1,
                    mBytesPerFrame: sizeofFloat,
                    mChannelsPerFrame: 1,
                    mBitsPerChannel: sizeofFloat * 8,
                    mReserved: 0)
    }
    
    func getDefaultOutput() -> AudioComponent {
        //
        // http://hondrouthoughts.blogspot.com/2014/09/livecoding-with-swift-audio-continued.html
        //
        var defaultOutputDescription = getAudioComponentDescription()
        
        let defaultOutput : AudioComponent = AudioComponentFindNext(nil, &defaultOutputDescription)
        print("defaultOutput=", defaultOutput)
        return defaultOutput
    }
    
    //
    // http://stackoverflow.com/questions/32290485/audiotoolbox-c-function-pointers-and-swift
    //
    func setCallback() -> Void {
        var input = AURenderCallbackStruct(inputProc: sampleShader, inputProcRefCon: UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque()))
        
        let err = AudioUnitSetProperty(
            gen,
            kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0,
            &input,
            UInt32(sizeof(input.dynamicType)))
            print("callback set err=", err)
    
        print("Creation err =", err)
    }
    
    func setFormat() -> Void {
        var streamFormat = getAudioStreamBasicDescription()
        let err = AudioUnitSetProperty(
            gen,
            kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0,
            &streamFormat, UInt32(sizeof(AudioStreamBasicDescription)))
        print("format err=", err)
        
    }
    
    func genCreate() -> Void {
        let defaultOutput = getDefaultOutput()
        AudioComponentInstanceNew(defaultOutput, &gen);
        setCallback()
        setFormat()
    }
    
    @IBAction func togglePlay(selectedButton: UIButton) {
        if gen != nil {
            AudioOutputUnitStop(gen)
            AudioUnitUninitialize(gen)
            AudioComponentInstanceDispose(gen)
            gen = nil;
            
            selectedButton.setTitle("Off", forState: UIControlState(rawValue:0))
        } else {
            genCreate()
            
            var err = AudioUnitInitialize(gen);
            print("Init err =", err)
            
            err = AudioOutputUnitStart(gen);
            print("Start err=", err)
            
            selectedButton.setTitle("On", forState: UIControlState(rawValue:0))
        }
    }
    
    func stop() -> Void {
        if gen != nil {
            togglePlay(playButton)
        }
    }
    
}

