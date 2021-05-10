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
//        self.tableView.reloadData()
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
