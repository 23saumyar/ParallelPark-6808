/*
 Copyright (c) 2015 Fernando Reynoso
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import CoreBluetooth

public enum BLEState : Int, CustomStringConvertible {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    
    public var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .resetting: return "Resetting"
        case .unsupported: return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff: return "Powered off"
        case .poweredOn: return "Powered on"
        }
    }
}

extension CBManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .resetting: return "Resetting"
        case .unsupported: return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff: return "Powered off"
        case .poweredOn: return "Powered on"
        }
    }
}

protocol BLEDelegate {
    func ble(didUpdateState state: BLEState)
    func ble(didDiscoverPeripheral peripheral: CBPeripheral)
    func ble(didConnectToPeripheral peripheral: CBPeripheral)
    func ble(didDisconnectFromPeripheral peripheral: CBPeripheral)
    func ble(_ peripheral: CBPeripheral, didReceiveData data: Data?)
}

private extension CBUUID {
    enum RedBearUUIDfront: String {
        case servicef = "713D0000-503E-4C75-BA94-3148F18D941A"
        case charTxf = "713D0002-503E-4C75-BA94-3148F18D941A"
        case charRxf = "713D0003-503E-4C75-BA94-3148F18D941A"
    }
    
    convenience init(redBearType: RedBearUUIDfront) {
        self.init(string:redBearType.rawValue)
    }
    
    
    enum RedBearUUIDmirror: String {
        case servicem = "713D0000-503E-4C75-BA94-3148F18D941B"
        case charTxm = "713D0002-503E-4C75-BA94-3148F18D941B"
        case charRxm = "713D0003-503E-4C75-BA94-3148F18D941B"
    }
    
    convenience init(redBearType: RedBearUUIDmirror) {
        self.init(string:redBearType.rawValue)
    }
    
    
    enum RedBearUUIDside: String {
        case services = "713D0000-503E-4C75-BA94-3148F18D941C"
        case charTxs = "713D0002-503E-4C75-BA94-3148F18D941C"
        case charRxs = "713D0003-503E-4C75-BA94-3148F18D941C"
    }
    
    convenience init(redBearType: RedBearUUIDside) {
        self.init(string:redBearType.rawValue)
    }
    
    
    enum RedBearUUIDback: String {
        case serviceb = "713D0000-503E-4C75-BA94-3148F18D941D"
        case charTxb = "713D0002-503E-4C75-BA94-3148F18D941D"
        case charRxb = "713D0003-503E-4C75-BA94-3148F18D941D"
    }
    
    convenience init(redBearType: RedBearUUIDback) {
        self.init(string:redBearType.rawValue)
    }
}

class BLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let RBL_CHAR_TX_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_RX_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
//    let RBL_SERVICE_UUIDfront = "713D0000-503E-4C75-BA94-3148F18D941E"
//    let RBL_CHAR_TX_UUIDfront = "713D0002-503E-4C75-BA94-3148F18D941E"
//    let RBL_CHAR_RX_UUIDfront = "713D0003-503E-4C75-BA94-3148F18D941E"
//
//    let RBL_SERVICE_UUIDmirror = "713D0000-503E-4C75-BA94-3148F18D941F"
//    let RBL_CHAR_TX_UUIDmirror = "713D0002-503E-4C75-BA94-3148F18D941F"
//    let RBL_CHAR_RX_UUIDmirror = "713D0003-503E-4C75-BA94-3148F18D941F"
//
//    let RBL_SERVICE_UUIDside = "713D0000-503E-4C75-BA94-3148F18D941G"
//    let RBL_CHAR_TX_UUIDside = "713D0002-503E-4C75-BA94-3148F18D941G"
//    let RBL_CHAR_RX_UUIDside = "713D0003-503E-4C75-BA94-3148F18D941G"
//
//    let RBL_SERVICE_UUIDback = "713D0000-503E-4C75-BA94-3148F18D941H"
//    let RBL_CHAR_TX_UUIDback = "713D0002-503E-4C75-BA94-3148F18D941H"
//    let RBL_CHAR_RX_UUIDback = "713D0003-503E-4C75-BA94-3148F18D941H"
    
    var delegate: BLEDelegate?
    
    private      var centralManager:   CBCentralManager!
    private      var activePeripheral: CBPeripheral?
    private      var characteristics = [String : CBCharacteristic]()
    private      var data:             NSMutableData?
    private(set) var peripherals     = [CBPeripheral]()
    private      var RSSICompletionHandler: ((NSNumber?, Error?) -> ())?
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.data = NSMutableData()
    }
    
    @objc private func scanTimeout() {
        
        print("[DEBUG] Scanning stopped")
        self.centralManager.stopScan()
    }
    
    // MARK: Public methods
    func startScanning(timeout: Double) -> Bool {
        
        if centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t start scanning")
            return false
        }
        
        print("[DEBUG] Scanning started")
        
        // CBCentralManagerScanOptionAllowDuplicatesKey
        
        Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(BLE.scanTimeout), userInfo: nil, repeats: false)
        
        let services:[CBUUID] = [CBUUID(redBearType: .servicef), CBUUID(redBearType: .servicem), CBUUID(redBearType: .services), CBUUID(redBearType: .serviceb)]
        centralManager.scanForPeripherals(withServices: services, options: nil)
//
//        let servicesmirror:[CBUUID] = [CBUUID(redBearType: .servicem)]
//        centralManager.scanForPeripherals(withServices: servicesmirror, options: nil)
//
//        let servicesside:[CBUUID] = [CBUUID(redBearType: .services)]
//        centralManager.scanForPeripherals(withServices: servicesside, options: nil)
//
//        let servicesback:[CBUUID] = [CBUUID(redBearType: .serviceb)]
//        centralManager.scanForPeripherals(withServices: servicesback, options: nil)
        return true
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) -> Bool {
        
        if centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t connect to peripheral")
            return false
        }
        
        print("[DEBUG] Connecting to peripheral: \(peripheral.identifier.uuidString)")
        
        centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(value: true)])
        
        return true
    }
    
    func disconnectFromPeripheral(_ peripheral: CBPeripheral) -> Bool {
        
        if centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t disconnect from peripheral")
            return false
        }
        
        centralManager.cancelPeripheralConnection(peripheral)
        
        return true
    }
    
    func read() {
        
        guard let char = characteristics[RBL_CHAR_TX_UUID] else { return }
        
        activePeripheral?.readValue(for: char)
    }
    
    func write(data: NSData) {
        
        guard let char = characteristics[RBL_CHAR_RX_UUID] else { return }
        
        activePeripheral?.writeValue(data as Data, for: char, type: .withoutResponse)
    }
    
    func enableNotifications(enable: Bool) {
        
        guard let char = characteristics[RBL_CHAR_TX_UUID] else { return }
        
        activePeripheral?.setNotifyValue(enable, for: char)
    }
    
    func readRSSI(completion: @escaping (_ RSSI: NSNumber?, _ error: Error?) -> ()) {
        
        RSSICompletionHandler = completion
        activePeripheral?.readRSSI()
    }
    
    // MARK: CBCentralManager delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("[DEBUG] Central manager state: \(central.state)")
        
        delegate?.ble(didUpdateState: BLEState(rawValue: central.state.rawValue)!)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("[DEBUG] Find peripheral: \(peripheral.identifier.uuidString) RSSI: \(RSSI)")
        
        let index = peripherals.index { $0.identifier.uuidString == peripheral.identifier.uuidString }
        
        if let index = index {
            peripherals[index] = peripheral
        } else {
            peripherals.append(peripheral)
        }
        
        delegate?.ble(didDiscoverPeripheral: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("[ERROR] Could not connect to peripheral \(peripheral.identifier.uuidString) error: \(error!.localizedDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("[DEBUG] Connected to peripheral \(peripheral.identifier.uuidString)")
        
        activePeripheral = peripheral
        
        activePeripheral?.delegate = self
        activePeripheral?.discoverServices([CBUUID(redBearType: .servicef), CBUUID(redBearType: .servicem), CBUUID(redBearType: .services), CBUUID(redBearType: .serviceb)])
        
        delegate?.ble(didConnectToPeripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        var text = "[DEBUG] Disconnected from peripheral: \(peripheral.identifier.uuidString)"
        
        if error != nil {
            text += ". Error: \(error!.localizedDescription)"
        }
        
        print(text)
        
        activePeripheral?.delegate = nil
        activePeripheral = nil
        characteristics.removeAll(keepingCapacity: false)
        
        delegate?.ble(didDisconnectFromPeripheral: peripheral)
    }
    
    // MARK: CBPeripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            print("[ERROR] Error discovering services. \(error!.localizedDescription)")
            return
        }
        
        print("[DEBUG] Found services for peripheral: \(peripheral.identifier.uuidString)")
        
        
        for service in peripheral.services! {
            let theCharacteristics = [CBUUID(redBearType: .charRxf), CBUUID(redBearType: .charTxf), CBUUID(redBearType: .charRxm), CBUUID(redBearType: .charTxm), CBUUID(redBearType: .charRxs), CBUUID(redBearType: .charTxs), CBUUID(redBearType: .charRxb), CBUUID(redBearType: .charTxb)]
            
            peripheral.discoverCharacteristics(theCharacteristics, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            print("[ERROR] Error discovering characteristics. \(error!.localizedDescription)")
            return
        }
        
        print("[DEBUG] Found characteristics for peripheral: \(peripheral.identifier.uuidString)")
        
        for characteristic in service.characteristics! {
            characteristics[characteristic.uuid.uuidString] = characteristic
        }
        
        enableNotifications(enable: true)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            
            print("[ERROR] Error updating value. \(error!.localizedDescription)")
            return
        }
        
        if characteristic.uuid.uuidString == RBL_CHAR_TX_UUID {
            delegate?.ble(peripheral, didReceiveData: characteristic.value as Data?)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        RSSICompletionHandler?(RSSI, error)
        RSSICompletionHandler = nil
    }
}
