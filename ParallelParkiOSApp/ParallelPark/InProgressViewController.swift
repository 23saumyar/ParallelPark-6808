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

    convenience init(sensor: Sensor?) {
       //TODO
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SensorModel.shared.delegate = self
        park()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SensorModel delegation
    
    func sensorModel(_ model: SensorModel, didChangeActiveSensor sensor: Sensor?) {
        // TODO: determine what sensors are which ones
        if sensor?.name == "front" {
            frontSensor = sensor!
            sensors.append(frontSensor)
        } else if sensor?.name == "mirror" {
            mirrorSensor = sensor!
            sensors.append(mirrorSensor)
        } else if sensor?.name == "side" {
            sideSensor = sensor!
            sensors.append(sideSensor)
        } else if sensor?.name == "back" {
            backSensor = sensor!
            sensors.append(backSensor)
        }
//        self.tableView.reloadData()
    }
    
    func sensorModel(_ model: SensorModel, didReceiveReadings readings: [Reading], forSensor sensor: Sensor?) {
        if sensor?.name == "front" {
            frontSensor = sensor!
            sensors.append(frontSensor)
        } else if sensor?.name == "mirror" {
            mirrorSensor = sensor!
            sensors.append(mirrorSensor)
        } else if sensor?.name == "side" {
            sideSensor = sensor!
            sensors.append(sideSensor)
        } else if sensor?.name == "back" {
            backSensor = sensor!
            sensors.append(backSensor)
        }
//        self.tableView.reloadData()
    }
    
/*
// working parking pseudo code:
    
    func park() {
        
        var state: Int = 0
        var threshold: Int = 0
        var threeFeetInMillimeter = 3*305
        
        // if user clicks start:
            // state = 1
        
        while state == 1 {
            // update side and mirror values
            
            // if inRange(mirror, threeFeetInMillimeter, threshold) && inRange(side, threeFeetInMillimeter, threshold {
                // store IMU measurements
                // command user to begin backing up until the back measurement goes over 3 ft
                state = 2
        // } else if inRange(mirror, threeFeetInMillimeter, threshold) && (side > (threeFeetInMillimeter+threshold)) {
                // command user to move up until both sensors have measurements in range
        // } else if inRange(side, threeFeetInMillimeter, threshold) && (mirror > (threeFeetInMillimeter+threshold)) {
                // command user to back up until both sensors have measurements in range

        }
        
    }
    
    
*/
    
/*
     
OG Parking Pseudo Code
     
    # if user clicks start, state = 1
     
    // state 1 - preparing starting position

    while state == 1:
        # if mirror in range (3ft+threshold) and side in range (3ft+threshold):
            # store IMU measurements to determine straightness later
            # command user to begin backing up until the back measurement goes over 3 ft
            # switch state

        # if mirror in range and side > (3ft+threshold):
            # command user to move up until both sensors have measurements in range

        # if mirror > (3ft+threshold) and side in range
            # command user to back up until both sensors have measurements in range
        
        # else:
            # command user to pull up about 3 feet from the car in front of the desired parking spot and try again


    // state 2 - backing up until ready to turn wheel

    while state == 2:
        # if mirror in range (3ft+threshold) and side in range (3ft+threshold):
            # command user to begin backing up until the back measurement goes over 3 ft
            # switch to state 3

        # else if mirror in range and side > range:
            # command user to turn the wheel one full rotation to the right, making sure no cars are coming, and then start moving backwards slowly

        # else:
            # print your position doesn't seem right, perhaps try again
            # switch to state 1


    // state 3 - backing up diagonally into spot

    while state == 3:
        # check angle
        # if angle ~ 45 degrees
            # mirror < (1ft+threshold) or distance starts increasing:
                # command user to stop, mirror should be at vehicle's tail light
                # command user to rotate wheel fully to the left and continue backing up until IMU measurements match OG measurements indicating straightened out
                # command user to straighten wheel
                # switch to state 4
        # if angle > 45 degrees:
            # command user to turn wheel a little in (?) direction
        # if angle < 45 degrees:
            # command user to turn wheel a little in (?) direction


    // state 4 - straighten wheel and center

    while state == 4:
        # if abs(front-back) < threshold (?):
            # print congratulations!
            # switch to state 5
        # else if front > back:
            # slowly back up
        # else if back > front:
            # slowly inch up


    // state 5 - completed
     
     if state == 5:
        # display completed screen
        state = 0

*/
    
// parking helper functions
    
    // determine whether a number is within the distance+threshold of another number
    func inRange(number: Int, target: Int, threshold: Int) -> Bool {
        if number > (target-threshold) && number < (target+threshold) {
            return true
        } else {
            return false
        }
    }
    
    // calculate and return angle of car compared to original measurement based on latest IMU readings
    func caclulateAngle() {
        return
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
