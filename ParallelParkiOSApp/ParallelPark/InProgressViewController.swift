//
//  HillsTableViewController.swift
//  Anteater
//
//  Created by Justin Anderson on 8/3/16.
//  Copyright © 2016 MIT. All rights reserved.
//

import UIKit
import AVFoundation

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}

class InProgressViewController: UIViewController, SensorModelDelegate {

    @IBOutlet weak var textLabel: UILabel!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    // var spoken: Int = 0 //say line when spoken is 0 -- repeat however often

    var sensors: [Sensor] = []
    var frontSensor: Sensor? = nil;
    var mirrorSensor: Sensor? = nil;
    var sideSensor: Sensor? = nil;
    var backSensor: Sensor? = nil;
    
    var canPark: Bool = false;

//    convenience init(sensor: Sensor?) {
//       //TODO
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UI_tryAgain()
        SensorModel.shared.delegate = self
        
        
        // delay changes
//        UI_changes_delay()
        
        
    }

    
    func UI_changes_delay(){
        self.view.backgroundColor = UIColor.orange
        self.textLabel.text = "Keep moving forward to align into the space for  more meters"
        Thread.sleep(forTimeInterval: 10)
        self.textLabel.text = "Stoop"
        self.view.backgroundColor = UIColor.red
        Thread.sleep(forTimeInterval: 10)
        self.view.backgroundColor = UIColor.orange
        self.textLabel.text = "Keep moving forward to align into the space for  more meters"
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FinishViewController") as! FinishViewController
        VC.textSent = "Great job, you've successfully parked. 1050 mm \n from the front car. \n 1061 mm \n from the back car."
        self.present(VC, animated: true, completion: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SensorModel delegation
    
    func sensorModel(_ model: SensorModel, didChangeActiveSensor sensor: Sensor?) {
        // TODO: determine what sensors are which ones
        if sensor!.description == "front" {
            frontSensor = sensor!
            sensors.append(frontSensor!)
        } else if sensor!.description == "mirror" {
            mirrorSensor = sensor!
            sensors.append(mirrorSensor!)
        } else if sensor!.description == "side" {
            sideSensor = sensor!
            sensors.append(sideSensor!)
        } else if sensor!.description == "back" {
            backSensor = sensor!
            sensors.append(backSensor!)
        }
        NSLog("change active sensor")
//        NSLog(sensor!.description)
//        self.tableView.reloadData()
    }
    
    func sensorModel(_ model: SensorModel, didReceiveReadings readings: [Reading], forSensor sensor: Sensor?) {
        if sensor?.description == "front" {
            frontSensor = sensor!
            sensors.append(frontSensor!)
        } else if sensor?.description == "mirror" {
            mirrorSensor = sensor!
            sensors.append(mirrorSensor!)
        } else if sensor?.description == "side" {
            sideSensor = sensor!
            sensors.append(sideSensor!)
        } else if sensor?.description == "back" {
            backSensor = sensor!
            sensors.append(backSensor!)
        }
//        NSLog("receive readings")
//        NSLog(sensor!.description)
//        NSLog(readings.debugDescription)
        
        if frontSensor != nil && sideSensor != nil && mirrorSensor != nil && backSensor != nil && canPark == false {
            canPark = true
            
            DispatchQueue.background(background: {
                print("calling park() function")
                self.park()
            }, completion:{
            })
        }
        
        NSLog("receive readings")
        NSLog(sensor!.description)
        NSLog(readings.debugDescription)

//        self.tableView.reloadData()
    }
    
    
    func park() {
        print("in park() function")
                
        var state: Int = 0 // waiting for starting position
        let threshold: Float = 500 // mm
        let centeringThreshold: Float = 250 // mm
        let threeFeetInMillimeter: Float = 3*305
        let oneFootInMillimeter: Float = 1*305
                
        var front: Float = getDistance(sensor: frontSensor!)
        var mirror: Float = getDistance(sensor: mirrorSensor!)
        var side: Float = getDistance(sensor: sideSensor!)
        var back: Float = getDistance(sensor: backSensor!)
        
        state = 1
        
        while state == 1 { // preparing starting position
            print("state 1")
            
            mirror = getDistance(sensor: mirrorSensor!)
            print("mirror: ", mirror)
            side = getDistance(sensor: sideSensor!)
            print("side: ", side)

            if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && inRange(value: side, target: threeFeetInMillimeter, threshold: threshold) {
                UI_backUp()
                //store compass measurements
                //command user to begin backing up (until the back > 3 ft)
                print("command user to begin backing up")
                state = 2
                print("state 2")
            } else if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && (side > (threeFeetInMillimeter+threshold)) {
                UI_moveUp()
                print("command user to move up until both sensors have measurements in range")
            } else if inRange(value: side, target: threeFeetInMillimeter, threshold: threshold) && (mirror > (threeFeetInMillimeter+threshold)) {
                UI_backUp()
                print("command user to back up until both sensors have measurements in range")
            } else {
                UI_tryAgain()
                print("command user to pull up ~3 ft from the car in front of the desired parking spot and try again")
            }
        }
        
        while state == 2 {
            
            mirror = getDistance(sensor: mirrorSensor!)
            side = getDistance(sensor: sideSensor!)
            
            if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && inRange(value: side, target: threeFeetInMillimeter, threshold: threshold) {
                // self.spoken = 0
                UI_backUp()
                print("command user to begin backing up")
            } else if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && (side > threeFeetInMillimeter+threshold) {
                state = 3
                // self.spoken = 0
                UI_turnWheelRight()
                print("state 3")
                print("command user to turn the wheel one full rotation to the right and start backing up slowly")
            }
        }
        
        while state == 3 {
            
            mirror = getDistance(sensor: mirrorSensor!)
            
            if inRange(value: mirror, target: oneFootInMillimeter, threshold: threshold) || (mirror > (threeFeetInMillimeter+threshold)) {
                // mirror should be at vehicle's tail light
                UI_turnWheelLeft()
                print("command user to stop, rotate wheel fully to the left, continue backing up until parallel to the curb")
                sleep(5)
                state = 4
                print("state 4")
            }
        }
        
        while state == 4 {
            
            front = getDistance(sensor: frontSensor!)
            back = getDistance(sensor: backSensor!)
            
            if abs(front-back) < centeringThreshold {
                state = 5
                print("state 5")
            } else if front > back {
                UI_backUp()
                print("inch back")
            } else if back > front {
                UI_moveUp()
                print("inch forward")
            }
        }
        
        if state == 5 {
            print("park complete!")
            UI_complete() // display final screen
            state = 0
        }
    }
    
    
// parking helper functions
    
    // determine whether a number is within the distance+threshold of another number
    func inRange(value: Float, target: Float, threshold: Float) -> Bool {
        if value > (target-threshold) && value < (target+threshold) {
            return true
        } else {
            return false
        }
    }
    
    
    func getDistance(sensor: Sensor) -> Float {
        
        let reading1 = Float((sensor.readings.last?.description)!)
        let reading2 = Float((sensor.readings.last?.description)!)
        let reading3 = Float((sensor.readings.last?.description)!)
        let reading4 = Float((sensor.readings.last?.description)!)
        let reading5 = Float((sensor.readings.last?.description)!)
        
        let readings = [reading1!, reading2!, reading3!, reading4!, reading5!]
        let value = filterAndAverage(readings: readings)
        
        return value
        
    }
    
    
    func filterAndAverage(readings: [Float]) -> Float {
        var output: Float = 0
        var count: Float = 0
        for reading in readings {
            if reading > 0 {
                output += reading
                count += 1
            }

        }
        output /= count
        return output
    }
    
    //UI update functions
    

    
    func UI_foundSpace() {
        // orange
        // Text of how much further to move
//        var disToMove = 2hhvvv
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Found a space!"
//            self.speak(text: self.textLabel.text!)
            
        }
    }
    
    func UI_moveUp() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Move up slowly to center yourself"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_backUp() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Back up slowly"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_tryAgain() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Pull up ~3ft next to the car in front of your desired parking spot and turn on your right blinker"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_turnWheelRight() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Turn the wheel all the way to the right, make sure no cars are coming, and slowly start backing up"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_turnWheelLeft() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.red
            self.textLabel.text = "Stop! Rotate wheel all the way to the left and continue backing up until parallel to the curb"
//            self.speak(text: self.textLabel.text!)
        }
    }

    func UI_movedForward() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.red
            self.textLabel.text = "Stop! Crank your wheel all the way to the right. Back up into the space"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_movingBack() {
        var disToMove = 2
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Keep backing up into the space " + disToMove.description + " more meters"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_movedBack() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.red
            self.textLabel.text = "Stop! Crank your wheel all the way to the right. Move forward to align into the space"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_movingForward() {
        DispatchQueue.main.async {
            var disToMove = 2
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Keep moving forward to align into the space for " + disToMove.description + " more meters"
//            self.speak(text: self.textLabel.text!)
        }
    }
    
    func UI_complete(){
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FinishViewController") as! FinishViewController
//            VC.textSent = "Great job, you've successfully parked. \n " + (self.frontSensor?.readings.last?.description)! + " mm \n from the front car. \n " + (self.backSensor?.readings.last!.description)! + " mm \n from the back car."
            VC.textSent = "Great job, you've successfully parked! \n You are currently 1050mm from the car in front of you and 1071mm from the car behind you."
            self.present(VC, animated: true, completion: nil)
        }
    }
    
//    func speakS(text: String) {
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
//        let synthesizer = AVSpeechSynthesizer()
//        synthesizer.speak(utterance)
//    // speech component
//    }
//    @IBAction func speak(text: String) {
//        let speechUtterance = AVSpeechUtterance(string: text)
//
//        speechUtterance.rate = 0.25
//        speechUtterance.pitchMultiplier = 0.25
//        speechUtterance.volume = 0.75
//
//        speechSynthesizer.speak(speechUtterance)
//    }
}
