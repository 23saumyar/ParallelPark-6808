//
//  HillsTableViewController.swift
//  Anteater
//
//  Created by Justin Anderson on 8/3/16.
//  Copyright © 2016 MIT. All rights reserved.
//

import UIKit

class InProgressViewController: UIViewController, SensorModelDelegate {

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
        if sensor?.name == "front" {
            frontSensor = sensor!
            sensors.append(frontSensor!)
        } else if sensor?.name == "mirror" {
            mirrorSensor = sensor!
            sensors.append(mirrorSensor!)
        } else if sensor?.name == "side" {
            sideSensor = sensor!
            sensors.append(sideSensor!)
        } else if sensor?.name == "back" {
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
        
        var state: Int = 0 // waiting for starting position
        var threshold: Float = 50 // mm
        var angleThreshold: Float = 5 // mm
        var centeringThreshold: Float = 100 // mm
        var threeFeetInMillimeter: Float = 3*305
        var oneFootInMillimeter: Float = 1*305
        
        var originalIMU = 0
        
        var front: Float = 0
        var mirror: Float = 0
        var side: Float = 0
        var back: Float = 0
        
        
        // if user clicks start:
            // state = 1
        
        while state == 1 { // preparing starting position
            
            // update side and mirror values
            
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
    
    
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let sensor = SensorModel.shared.activeSensor {
//            return 1 + sensor.readings.count
//        } else {
//            return 1
//        }
//    }
//
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let sensor = SensorModel.shared.activeSensor else {
//            return tableView.dequeueReusableCell(withIdentifier: "noConnCell", for: indexPath)
//        }
//        switch indexPath.row {
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "plotCell", for: indexPath)
//            cell.imageView?.image = #imageLiteral(resourceName: "anteater-logo")
//            cell.textLabel?.text = "\(sensor.name) - \(sensor.readings.count) readings"
//            return cell
//        default:
//            let reading = sensor.readings.reversed()[indexPath.row - 1]
//            let cell = tableView.dequeueReusableCell(withIdentifier: "sensorCell", for: indexPath)
//
//            let formatter = DateFormatter()
//            formatter.dateStyle = .short
//            formatter.timeStyle = .short
//
//            cell.textLabel?.text = "\(reading)"
//            cell.detailTextLabel?.text = formatter.string(from: reading.date)
////            switch reading.type {
////            case .Temperature:
////                cell.imageView?.image = #imageLiteral(resourceName: "thermo")
////            case .Humidity:
////                cell.imageView?.image = #imageLiteral(resourceName: "humidity")
////            default:
////                break
////            }
//
//            return cell
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
//            // Push Core Plot graph
//            let vc = SensorDataPlotViewController(sensor: SensorModel.shared.activeSensor)
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
