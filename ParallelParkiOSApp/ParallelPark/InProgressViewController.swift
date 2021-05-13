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
    
    var canPark: Bool = false;

//    convenience init(sensor: Sensor?) {
//       //TODO
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            print("calling park() function")
            park()
        }

//        self.tableView.reloadData()
    }
    

// working parking pseudo code:
    
    func park() {
        print("in park() function")
        
        // sensor.readings.description
        
        var state: Int = 1 // waiting for starting position
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
        
        while state == 1 { // preparing starting position
            print("state 1")
            print("preparing starting position")
            
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
            print("state 2")
            
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
            print("state = 3")
            
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
            print("state 4")
            
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
            print("state 5")
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
        print(sensor.readings.last?.description)
//        let reading = sensor.readings.last?.description!
//        let value = Float(reading)
//        print("Sensor: ", sensor)
//        print("Sensor Reading: ", value)
//        return value
        return 0
        
    }
    
    // filter / smoothing function
    
    
    
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
