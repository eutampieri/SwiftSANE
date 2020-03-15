import Foundation
import Socket

enum SaneError: Error {
    case ConnectionError
}

struct SaneDetailedError: Error {
    var error: Error
    var description: String
}

class SANEScan {
    private let socket: Socket
    private let username: String
    private let saneVersion: SaneVersion?
    init(address: String) throws {
        self.username = "swiftscan\(Int.random(in: 1000000...9999999))"
        
        try self.socket = Socket.create()
        try socket.connect(to: address, port: 6566)
        
        let request = try SaneMessage([
            SaneRpc.Init,
            SaneVersion(major: 1, minor: 0, build: 3),
            self.username
        ]).saneEncode()
        try socket.write(from: request)
                
        var result = Data()
        let _ = try socket.read(into: &result)
        let parser = SaneDecoder(with: result)
        let status: SaneStatus = parser.extract()
        guard status == .OK else {
            throw SaneError.ConnectionError
        }
        saneVersion = parser.extract()
    }
    
    func listScanners() throws -> [SaneDevice] {
        let request = try SaneMessage([
            SaneRpc.GetDevices,
        ]).saneEncode()
        try socket.write(from: request)
                
        var result = Data()
        let breads = try socket.read(into: &result)
        print("Read \(breads) bytes, \(result.base64EncodedString())")
        let parser = SaneDecoder(with: result)
        let status: SaneStatus = parser.extract()
        guard status == .OK else {
            throw SaneError.ConnectionError
        }
        let arrayLength: Int = parser.extract() - 1
        var scanners: [SaneDevice] = []
        for _ in 0..<arrayLength {
            parser.discard(length: 4)
            scanners.append(SaneDevice(name: try parser.extract(), vendor: try parser.extract(), model: try parser.extract(), type: try parser.extract()))
        }
        return scanners
        //self.result = result.base64EncodedString()
    }
    
    func openDevice(name device: String) throws -> Int {
        let request = try SaneMessage([
            SaneRpc.Open,
            device
        ]).saneEncode()
        try socket.write(from: request)
        var result = Data()
        let _ = try socket.read(into: &result)
        let parser = SaneDecoder(with: result)
        let status: SaneStatus = parser.extract()
        guard status == .OK else {
            throw status
        }
        let handle: Int = parser.extract()
        let resource: String = try parser.extract()
        return handle
    }
    func closeDevice(handle: Int) throws {
        let request = try SaneMessage([
            SaneRpc.Close,
            handle
        ]).saneEncode()
        try socket.write(from: request)
        var result = Data()
        let _ = try socket.read(into: &result)
    }
    func getOptionDescriptors(for handle: Int) throws -> [SaneOption] {
        let request = try SaneMessage([
            SaneRpc.GetOptionDescriptors,
            handle
        ]).saneEncode()
        try socket.write(from: request)
        var response = Data()
        guard try socket.read(into: &response) > 0 else {
            throw SaneStatus.EOF
        }
        let parser = SaneDecoder(with: response)
        
        var result: [SaneOption] = []
        let length = (parser.extract() - 1)
        var extracted = 0
        while extracted < length {
            if parser.extract() == 0 {
                let option: SaneOption = try parser.extract()
                result.append(option)
                extracted+=1
            }
        }
        return result
    }

    /// A low level function that controls a SANE option. It returns a tuple
    func controlOption(handle: Int, option: Int, action: Int, type: SaneType, value: SaneEncodable) throws -> (Int, SaneType, SaneEncodable, String) {
        let request = try SaneMessage([
            SaneRpc.ControlOption,
            handle,
            option,
            action,
            type.rawValue,
            value.getLength(),
            (type == .String ? "\(value)\0".data(using: .ascii, allowLossyConversion: true)! :  value)
        ]).saneEncode()
        print("\na\n\(request.base64EncodedString())\na\n")
        try socket.write(from: request)
        var response = Data()
        guard try socket.read(into: &response) > 0 else {
            throw SaneStatus.EOF
        }
        let parser = SaneDecoder(with: response)
        print("repsonse: \(response.base64EncodedString())")
        let status: SaneStatus = parser.extract()
        guard status == SaneStatus.OK || status == SaneStatus.AccessDenied else {
            throw status
        }
        
        let info: Int = parser.extract()
        let type: SaneType = try parser.extract()
        let value: SaneEncodable
        switch type {
        case .Bool:
            parser.discard(length: 4)
            let int: Int = parser.extract()
            value = int == 1
        case .Int:
            parser.discard(length: 4)
            let int: Int = parser.extract()
            value = int
        case .Fixed:
            parser.discard(length: 4)
            let word = Float(parser.extract())
            value = word.fromWord()
        case .String:
            let str: String = try parser.extract()
            value = str
        case .Button:
            parser.discard(length: 4)
            let int: Int = parser.extract()
            value = int
        case .Group:
            parser.discard(length: 4)
            let int: Int = parser.extract()
            value = int
        }
        let resource: String = try parser.extract()
        if status == .AccessDenied {
            throw SaneDetailedError(error: status, description: resource)
        }
        return (info, type, value, resource)
    }

    
    func getParameters(for handle: Int) throws {
        let request = try SaneMessage([
            SaneRpc.GetParameters,
            handle
        ]).saneEncode()
        try socket.write(from: request)
        var response = Data()
        guard try socket.read(into: &response) > 0 else {
            throw SaneStatus.EOF
        }
        print("\(response.base64EncodedString())")
        //let parser = SaneDecoder(with: response)
    }
}
