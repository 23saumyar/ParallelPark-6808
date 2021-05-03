//
//  SensorModel.swift
//  Anteater
//
//  Created by Justin Anderson on 8/1/16.
//  Copyright © 2016 MIT. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

protocol SensorModelDelegate {
    func sensorModel(_ model: SensorModel, didChangeActiveHill hill: Hill?)
    func sensorModel(_ model: SensorModel, didReceiveReadings readings: [Reading], forHill hill: Hill?)
}

extension Notification.Name {
    public static let SensorModelActiveHillChanged = Notification.Name(rawValue: "SensorModelActiveHillChangedNotification")
    public static let SensorModelReadingsChanged = Notification.Name(rawValue: "SensorModelHillReadingsChangedNotification")
}

enum ReadingType: Int {
    case Unknown = -1
    case Humidity = 2
    case Temperature = 1
    case Error = 0
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
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        guard let numberString = formatter.string(from: NSNumber(value: self.value)) else {
            print("Double \"\(value)\" couldn't be formatted by NumberFormatter")
            return "NaN"
        }
        switch type {
        case .Temperature:
            return "\(numberString)°F"
        case .Humidity:
            return "\(numberString)%"
        default:
            return "\(type)"
        }
    }
}

struct Hill {
    var readings: [Reading]
    var name: String
    
    init(name: String) {
        readings = []
        self.name = name
    }
}

extension Hill: CustomStringConvertible, Hashable, Equatable {
    var description: String {
        return name
    }
    
    var hashValue: Int {
        return name.hashValue
    }
}

func ==(lhs: Hill, rhs: Hill) -> Bool {
    return lhs.name == rhs.name
}

class SensorModel : BLEDelegate{
    
    static let kBLE_SCAN_TIMEOUT = 10000.0
    
    static let shared = SensorModel()

    var delegate: SensorModelDelegate?
    var sensorReadings: [ReadingType: [Reading]] = [.Humidity: [], .Temperature: []]
    var activeHill: Hill?
    var ble: BLE?
    var activePeripheral: CBPeripheral?
    
    init() {
        ble = BLE()
        ble?.delegate = self
    }
    
    func ble(didUpdateState state: BLEState) {
        if(state == BLEState.poweredOn){
            // initiate scaning for anthills
            ble?.startScanning(timeout: 10)
        }
    }
    
    func ble(didDiscoverPeripheral peripheral: CBPeripheral) {
        ble?.connectToPeripheral(peripheral)
    }
    
    func ble(didConnectToPeripheral peripheral: CBPeripheral) {
        activeHill = Hill(name: peripheral.name!)
        activePeripheral = peripheral
        delegate?.sensorModel(self, didChangeActiveHill: activeHill)
        
        
        
    }
    
    func ble(didDisconnectFromPeripheral peripheral: CBPeripheral) {
        if (peripheral.name == activeHill?.name){
            activeHill = nil
            delegate?.sensorModel(self, didChangeActiveHill: activeHill)
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
        var r = ReadingType.Temperature
        if (str.hasPrefix("H")){
            r = ReadingType.Humidity
        }
        
        let reading = Reading(type: r, value: value, sensorId: peripheral.name)
        activeHill?.readings.append(reading)
        delegate?.sensorModel(self, didReceiveReadings: [reading], forHill: activeHill)
    }
    
    
}
