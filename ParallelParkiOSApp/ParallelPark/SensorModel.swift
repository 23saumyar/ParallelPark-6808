//
//  SensorModel.swift
//  ParallelPark
//
//  Created by Justin Anderson on 8/1/16.
//  Copyright © 2016 MIT. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

protocol SensorModelDelegate {
    func sensorModel(_ model: SensorModel, didChangeActiveSensor sensor: Sensor?)
    func sensorModel(_ model: SensorModel, didReceiveReadings readings: [Reading], forSensor sensor: Sensor?)
}

extension Notification.Name {
    public static let SensorModelActiveSensorChanged = Notification.Name(rawValue: "SensorModelActiveSensorChangedNotification")
    public static let SensorModelReadingsChanged = Notification.Name(rawValue: "SensorModelSensorReadingsChangedNotification")
}

enum ReadingType: Int {
    case Unknown = -1
    case Error = 0
    
    case Distance = 1
    case IMU_g = 2
    case IMU_a = 3
    case IMU_m = 4
}

struct Reading {
    let type: ReadingType
    let value: Double
    let date: Date = Date()
    let sensorId: String?
    
    func toJson() -> [String: Any] {
        return [
            "value": self.value,
            "type": self.type.rawValue,
            "timestamp": self.date.timeIntervalSince1970,
            "userid": UIDevice.current.identifierForVendor?.uuidString ?? "NONE",
            "sensorid": sensorId ?? "NONE"
        ]
    }
}

extension Reading: CustomStringConvertible {
    var description: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        guard let numberString = formatter.string(from: NSNumber(value: self.value)) else {
            print("Double \"\(value)\" couldn't be formatted by NumberFormatter")
            return "NaN"
        }
        switch type {
        case .Distance:
            return "\(numberString)m" //TODO: change to correct units
        case .IMU_g:
            return "\(numberString)deg"
        case .IMU_a:
            return "\(numberString)m/s^2"
        case .IMU_m:
            return "\(numberString)mag" //TODO: fix units
        default:
            return "\(type)"
        }
    }
}

struct Sensor {
    var readings: [Reading]
    var name: String
    
    init(name: String) {
        NSLog(name)
        readings = []
        self.name = name
    }
}

extension Sensor: CustomStringConvertible, Hashable, Equatable {
    var description: String {
        return name
    }
    
    var hashValue: Int {
        return name.hashValue
    }
}

func ==(lhs: Sensor, rhs: Sensor) -> Bool {
    return lhs.name == rhs.name
}

class SensorModel : BLEDelegate{
    
    static let kBLE_SCAN_TIMEOUT = 10000000.0
    
    static let shared = SensorModel()

    var delegate: SensorModelDelegate?
    var sensorReadings: [ReadingType: [Reading]] = [.Distance: [], .IMU_g: [], .IMU_a: [], .IMU_m:[]]
    var activeSensor: Sensor?
    var ble: BLE?
    var activePeripheral: CBPeripheral?
    
    init() {
        ble = BLE()
        ble?.delegate = self
    }
    
    func ble(didUpdateState state: BLEState) {
        if(state == BLEState.poweredOn){
            // initiate scaning for sensors
            ble?.startScanning(timeout: 10)
        }
    }
    
    func ble(didDiscoverPeripheral peripheral: CBPeripheral) {
        ble?.connectToPeripheral(peripheral)
    }
    
    func ble(didConnectToPeripheral peripheral: CBPeripheral) {
        activeSensor = Sensor(name: peripheral.name!)
        activePeripheral = peripheral
        delegate?.sensorModel(self, didChangeActiveSensor: activeSensor)
        
        
        
    }
    
    func ble(didDisconnectFromPeripheral peripheral: CBPeripheral) {
        if (peripheral.name == activeSensor?.name){
            activeSensor = nil
            delegate?.sensorModel(self, didChangeActiveSensor: activeSensor)
            ble?.startScanning(timeout: 10)
        }
    }
    
    func ble(_ peripheral: CBPeripheral, didReceiveData data: Data?) {
        // convert a non-nil Data optional into a String
        let str = String(data: data!, encoding: String.Encoding.ascii)!

        // get a substring that excludes the first and last characters
        let substring = str[str.index(after: str.startIndex)..<str.index(before: str.endIndex)]

        // convert a Substring to a Double
        let value = Double(substring.trimmingCharacters(in: .whitespacesAndNewlines))!
        var r = ReadingType.Distance
        if (str.hasPrefix("IMU_g")){ //TODO: change this
            r = ReadingType.IMU_g
        } else if (str.hasPrefix("IMU_a")){
            r = ReadingType.IMU_a
        } else if (str.hasPrefix("IMU_m")){
            r = ReadingType.IMU_m
        }
        
        let reading = Reading(type: r, value: value, sensorId: peripheral.name)
        activeSensor?.readings.append(reading)
        delegate?.sensorModel(self, didReceiveReadings: [reading], forSensor: activeSensor)
    }
    
    
}
