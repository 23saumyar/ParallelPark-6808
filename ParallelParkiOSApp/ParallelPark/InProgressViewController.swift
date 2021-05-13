//
//  HillsTableViewController.swift
//  Anteater
//
//  Created by Justin Anderson on 8/3/16.
//  Copyright © 2016 MIT. All rights reserved.
//

import UIKit

class InProgressViewController: UIViewController, SensorModelDelegate {

    @IBOutlet weak var textLabel: UILabel!

    var sensors: [Sensor] = []
    var frontSensor: Sensor? = nil;
    var mirrorSensor: Sensor? = nil;
    var sideSensor: Sensor? = nil;
    var backSensor: Sensor? = nil;

//    convenience init(sensor: Sensor?) {
//       //TODO
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UI_foundSpace()
        SensorModel.shared.delegate = self
        // park()
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
        NSLog("recieve readings")
        NSLog(sensor!.description)
        NSLog(readings.debugDescription)

//        self.tableView.reloadData()
    }
    

// working parking pseudo code:
    
    func park() {
        
        // sensor.readings.description
        
        var state: Int = 0 // waiting for starting position
        let threshold: Float = 50 // mm
        let angleThreshold: Float = 5 // mm
        let centeringThreshold: Float = 100 // mm
        let threeFeetInMillimeter: Float = 3*305
        let oneFootInMillimeter: Float = 1*305
        
//        var originalIMU = 0
        
        var front: Float = getDistance(sensor: frontSensor!)
        var mirror: Float = getDistance(sensor: mirrorSensor!)
        var side: Float = getDistance(sensor: sideSensor!)
        var back: Float = getDistance(sensor: backSensor!)
        
        // if user clicks start:
            // state = 1
        
        while state == 1 { // preparing starting position
            
            mirror = getDistance(sensor: mirrorSensor!)
            side = getDistance(sensor: sideSensor!)
            
            if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && inRange(value: side, target: threeFeetInMillimeter, threshold: threshold) {
//                 store IMU measurements
//                 command user to begin backing up until the back measurement goes over 3 ft
                state = 2
            } else if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && (side > (threeFeetInMillimeter+threshold)) {
//                 command user to move up until both sensors have measurements in range
            } else if inRange(value: side, target: threeFeetInMillimeter, threshold: threshold) && (mirror > (threeFeetInMillimeter+threshold)) {
//                 command user to back up until both sensors have measurements in range
            } else {
//             command user to pull up about 3 feet from the car in front of the desired parking spot and try again
            }
        }
        
        while state == 2 {
            
            mirror = getDistance(sensor: mirrorSensor!)
            side = getDistance(sensor: sideSensor!)
            
            if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && inRange(value: side, target: threeFeetInMillimeter, threshold: threshold) {
//                command user to begin backing up until the back measurement goes over 3 ft
                state = 3
            } else if inRange(value: mirror, target: threeFeetInMillimeter, threshold: threshold) && (side > threeFeetInMillimeter+threshold) {
//                command user to turn the wheel one full rotation to the right, making sure no cars are coming, and then start moving backwards slowly
            } else {
//                print that the position doesn't seem right - perhaps try again
                state = 1
            }
        }
        
        while state == 3 {
            
            mirror = getDistance(sensor: mirrorSensor!)
            var angle: Float = calculateAngle()
            
            if inRange(value: angle, target: 45, threshold: angleThreshold) {
                if inRange(value: mirror, target: oneFootInMillimeter, threshold: threshold) || (mirror > (threeFeetInMillimeter+threshold)) {
//                    command user to stop, mirror should be at vehicle's tail light
//                    command user to rotate wheel fully to the left and continue backing up until IMU measurements match OG measurements indicating straightened out
//                    command user to straighten wheel
                    state = 4
                }
            } else if angle > (45+angleThreshold) {
//                command user to turn wheel a little in (?) direction
            } else if angle < (45+angleThreshold) {
//                command user to turn wheel a little in (?) direction
            }
        }
        
        while state == 4 {
            
            front = getDistance(sensor: frontSensor!)
            back = getDistance(sensor: backSensor!)
            
            if abs(front-back) < centeringThreshold {
                state = 5
            } else if front > back {
//                command user to slowly back up
            } else if back > front {
//                command user to slowly inch up
            }
        }
        
        if state == 5 {
            // display final screen
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
    
    // calculate and return angle of car compared to original measurement based on latest IMU readings
    func calculateAngle() -> Float {
        // TODO
        return 0
    }
    
    func getDistance(sensor: Sensor) -> Float {
        print("in getDistance function")
        
        let reading = Float(sensor.readings.description)
        print("Sensor: ", sensor)
        print("Sensor Reading: ", reading!)
        return reading!
        
    }
    
    // filter / smoothing function
    
    
    

    
    
    
    //UI changes
    
    func UI_foundSpace() {
        // orange
        // Text of how much further to move
        var disToMove = 2
        self.view.backgroundColor = UIColor.orange

        self.textLabel.text = "Found a space! Please move forward " + disToMove.description + " more meters"
    }
    
    func UI_movedForward() {
        self.view.backgroundColor = UIColor.red
        self.textLabel.text = "Stop! Crank your wheel all the way to the right. Back up into the space"
    }
    
    func UI_movingBack() {
        var disToMove = 2
        self.view.backgroundColor = UIColor.orange
        self.textLabel.text = "Keep backing up into the space " + disToMove.description + " more meters"
    }
    
    func UI_movedBack() {
        self.view.backgroundColor = UIColor.red
        self.textLabel.text = "Stop! Crank your wheel all the way to the right. Move forward to align into the space"
    }
    
    func UI_movingForward() {
        var disToMove = 2
        self.view.backgroundColor = UIColor.orange
        self.textLabel.text = "Keep moving forward to align into the space for " + disToMove.description + " more meters"
    }
    
    func UI_complete(){
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "FinishViewController") as! FinishViewController
        self.present(VC, animated: true, completion: nil)
    }
}
