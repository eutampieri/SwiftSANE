//
//  SANEWire.swift
//  SANEScan
//
//  Created by Eugenio Tampieri on 05/03/2020.
//

import Foundation

private func saneVersionCode(major: Int32, minor: Int32, build: Int32) -> Int32 {
return (  (((major) &   0xff) << 24)
 | (((minor) &   0xff) << 16)
 | (((build) & 0xffff) <<  0))
}

enum CodecError: Error {
    case InvalidDescription
    case MalformedData
    case InvalidString
    case UnknownType
}

struct SaneMessage: SaneEncodable {
    func saneEncode() throws -> Data {
        var result = Data()
        for value in self.storage {
            try result.append(value.saneEncode())
        }
        return result
    }
    
    func getLength() -> Int {
        var result = 0
        for value in self.storage {
            result += value.getLength()
        }
        return result
    }
    
    var storage: [SaneEncodable]
    init(_ data: [SaneEncodable]) {
        storage = data
    }
}

/// A SANE representable value, with the SANE codec protocol
protocol SaneEncodable {
    func saneEncode() throws -> Data
    /// Function that gets the field's length from data, used for encoding
    func getLength() -> Int
    /// Function that gets the field's length from raw data, used for decoding
    //func getLength(from: Data) -> Int
}

/// SANE codec for arrays of SANE values
extension Array: SaneEncodable where Element == SaneEncodable {
    func getLength() -> Int {
        var result = 0
        for value in self {
            result += value.getLength()
        }
        return result
    }
    
    func saneEncode() throws -> Data {
        var result = Data()
        for value in self {
            try result.append(value.saneEncode())
        }
        return result
    }
}

/// Codec for SANE values
/*extension SaneValue: SaneEncodable {
    func getLength() -> Int {
        switch self {
        case .Array(let array):
            return array!.getLength()
        case .Int(_):
            return 4
        case .Raw(let data):
            return data!.count
        case .RPC(_):
            return 4
        case .Status(_):
            return 4
        case .String(let str):
            return str!.getLength()
        case .Version(_):
            return 4
        }
    }
    
    func getLength(from: Data) -> Int {
        switch self {
        case .Array(let array):
            return array!.getLength()
        case .String(let str):
            return str!.getLength()
        /// For fixed-length fields we return the fixed length
        default:
            return self.getLength()
        }
    }
    
    func decode(from: Data) throws -> [SaneValue] {
        <#code#>
    }
    
    func encode() throws -> Data {
        switch self {
        case .Array(let val):
            return try val!.encode()
        case .Int(let val):
            var data = Data()
            var bigEndian = val!.bigEndian
            data.append(UnsafeBufferPointer(start: &bigEndian, count: 1))
            return data
        case .Raw(let data):
            return data!
        case .RPC(let val):
            return try SaneValue.Int(val!.rawValue).encode()
        case .Status(let val):
            return try SaneValue.Int(val!.rawValue).encode()
        case .String(let val):
            return try val!.encode()
        case .Version(let val):
            return try SaneValue.Int(saneVersionCode(major: Int32(val!.major), minor: Int32(val!.minor), build: Int32(val!.build))).encode()
        }
    }
}*/

/// String codec
extension String: SaneEncodable {
    func getLength() -> Int {
        return self.lengthOfBytes(using: .ascii) + 1
    }
            
    func saneEncode() throws -> Data {
        return try SaneMessage([
            Int32(self.getLength()),
            "\(self)\0".data(using: .ascii, allowLossyConversion: true)!
        ]).saneEncode()
    }
}

/// Integer codec
extension Int: SaneEncodable {
    func saneEncode() throws -> Data {
        return try Int32(self).saneEncode()
    }
    
    func getLength() -> Int {
        return Int32(self).getLength()
    }
    
}
extension Int32: SaneEncodable {
    func saneEncode() throws -> Data {
        var data = Data()
        var bigEndian = self.bigEndian
        data.append(UnsafeBufferPointer(start: &bigEndian, count: 1))
        return data
    }
    
    func getLength() -> Int {
        return 4
    }
}
/// Raw encoder
extension Data: SaneEncodable {
    func saneEncode() throws -> Data {
        return self
    }
    
    func getLength() -> Int {
        return 4
    }
}

extension SaneRpc: SaneEncodable {
    func saneEncode() throws -> Data {
        return try self.rawValue.saneEncode()
    }
    
    func getLength() -> Int {
        return self.rawValue.getLength()
    }
}

extension SaneVersion: SaneEncodable {
    func saneEncode() throws -> Data {
        return try saneVersionCode(major: Int32(self.major), minor: Int32(self.minor), build: Int32(self.build)).saneEncode()
    }
    
    func getLength() -> Int {
        return 4
    }
}

extension Float: SaneEncodable {
    func getLength() -> Int {
        return 0.getLength()
    }
    
    func saneEncode() throws -> Data {
        return try Int(self * Float(1 << 16)).saneEncode()
    }
}

extension Double: SaneEncodable {
    func getLength() -> Int {
        return 0.getLength()
    }
    
    func saneEncode() throws -> Data {
        return try Float(self).saneEncode()
    }
}

extension Bool: SaneEncodable {
    func getLength() -> Int {
        return 0.getLength()
    }
    
    func saneEncode() throws -> Data {
        return try Int(self ? 1 : 0).saneEncode()
    }
}
