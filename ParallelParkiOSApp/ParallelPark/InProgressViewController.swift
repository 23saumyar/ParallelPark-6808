//
//  HillsTableViewController.swift
//  Anteater
//
//  Created by Justin Anderson on 8/3/16.
//  Copyright © 2016 MIT. All rights reserved.
//

import UIKit

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
        UI_foundSpace()
        SensorModel.shared.delegate = self
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
        NSLog(sensor!.description)
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
        NSLog("receive readings")
        NSLog(sensor!.description)
        NSLog(readings.debugDescription)
        
        if frontSensor != nil && sideSensor != nil && mirrorSensor != nil && backSensor != nil && canPark == false {
            canPark = true
            
            DispatchQueue.background(background: {
                // do something in background
                
                print("calling park() function")
                self.park()
                
            }, completion:{
                // when background job finished, do something in main thread
                
            })
            

        }
        
        NSLog("receive readings")
        NSLog(sensor!.description)
        NSLog(readings.debugDescription)

//        self.tableView.reloadData()
    }
    

// working parking pseudo code:
    
    func park() {
        print("in park() function")
                
        var state: Int = 0 // waiting for starting position
        let threshold: Float = 100 // mm
//        let angleThreshold: Float = 5 // mm
        let centeringThreshold: Float = 100 // mm
        let threeFeetInMillimeter: Float = 3*305
        let oneFootInMillimeter: Float = 1*305
                
        var front: Float = getDistance(sensor: frontSensor!)
        var mirror: Float = getDistance(sensor: mirrorSensor!)
        var side: Float = getDistance(sensor: sideSensor!)
        var back: Float = getDistance(sensor: backSensor!)
        
        UI_foundSpace()
        sleep(5)
        state = 1
        
        while state == 1 { // preparing starting position
            print("state 1")
            
            mirror = getDistance(sensor: mirrorSensor!)
            print("mirror: ", mirror)
            side = getDistance(sensor: sideSensor!)
            print("side: ", side)

            if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && inRange(value: side, target: threeFeetInMillimeter, threshold: threshold) {
                UI_backUp()
                print("@user - start backing up!")
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
                UI_backUp()
                print("command user to begin backing up")
            } else if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && (side > threeFeetInMillimeter+threshold) {
                state = 3
                UI_turnWheelRight()
                print("state 3")
                print("command user to turn the wheel one full rotation to the right and start backing up slowly")
            } else {
                UI_tryAgain()
                print("position doesn't seem right - try starting over")
                state = 1
                print("state 1")
            }
        }
        
        while state == 3 {
            
            mirror = getDistance(sensor: mirrorSensor!)
            
            if inRange(value: mirror, target: oneFootInMillimeter, threshold: threshold) || (mirror > (threeFeetInMillimeter+threshold)) {
                // mirror should be at vehicle's tail light
                UI_turnWheelLeft()
                print("command user to stop, rotate wheel fully to the left, continue backing up until parallel to the curb")
                sleep(10)
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
        var disToMove = 2
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Found a space! Please move forward " + disToMove.description + " more meters"
        }
    }
    
    func UI_moveUp() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Move up slowly"
        }
    }
    
    func UI_backUp() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Back up slowly"
        }
    }
    
    func UI_tryAgain() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Pull up ~3ft next to the car in front of your desired parking spot and try again"
        }
    }
    
    func UI_turnWheelRight() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Turn the wheel one full rotation to the right, make sure no cars are coming, and slowly start backing up"
        }
    }
    
    func UI_turnWheelLeft() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.red
            self.textLabel.text = "Stop. Rotate wheel fully to the left and continue backing up until parallel to the curb"
        }
    }
    
    

    func UI_movedForward() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.red
            self.textLabel.text = "Stop! Crank your wheel all the way to the right. Back up into the space"
        }
    }
    
    func UI_movingBack() {
        var disToMove = 2
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Keep backing up into the space " + disToMove.description + " more meters"
        }
    }
    
    func UI_movedBack() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.red
            self.textLabel.text = "Stop! Crank your wheel all the way to the right. Move forward to align into the space"
        }
    }
    
    func UI_movingForward() {
        DispatchQueue.main.async {
            var disToMove = 2
            self.view.backgroundColor = UIColor.orange
            self.textLabel.text = "Keep moving forward to align into the space for " + disToMove.description + " more meters"
        }
    }
    
    func UI_complete(){
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "FinishViewController") as! FinishViewController
            self.present(VC, animated: true, completion: nil)
        }
    }
}
