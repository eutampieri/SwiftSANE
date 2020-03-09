//
//  Decoder.swift
//  SANEScan
//
//  Created by Eugenio Tampieri on 08/03/2020.
//

import Foundation

/// The representation of all the possible values occouring in a SANE message
/*enum SaneValue {
    /// A word
    case Int(Int32!)
    /// A NULL-terminated string
    case String(String!)
    /// An RPC code
    case RPC(SaneRpc!)
    /// A SANE version
    case Version(SaneVersion!)
    /// A SANE status
    case Status(SaneStatus!)
    /// Raw data
    case Raw(Data!)
}*/

protocol SaneDecodable {
    func getLength(from data: Data) -> Int
    func decode(from data: Data) throws -> SaneEncodable
}

extension Array: SaneDecodable where Element == SaneDecodable {
    func getLength(from data: Data) -> Int {
        var index = 0
        for element in self {
            index += element.getLength(from: data.advanced(by: index))
        }
        return index
    }
    
    func decode(from data: Data) throws -> SaneEncodable {
        var result: [SaneEncodable] = []
        var index = 0
        for element in self {
            try result.append(element.decode(from: data.advanced(by: index)))
            index += element.getLength(from: data.advanced(by: index))
        }
        return result
    }
}

extension String: SaneDecodable {
    func getLength(from data: Data) -> Int {
        return Int(data.first!).bigEndian
    }
    
    func decode(from data: Data) throws -> SaneEncodable {
        guard let x = String(data: data.subdata(in: 4..<(self.getLength() + 1)), encoding: .ascii) else {
            throw CodecError.InvalidString
        }
        return x
    }
}

extension Int: SaneDecodable {
    func getLength(from data: Data) -> Int {
        return 4
    }
    
    func decode(from data: Data) throws -> SaneEncodable {
        return data.withUnsafeBytes {
            (pointer: UnsafePointer<Int32>) -> Int32 in
            return pointer.pointee.bigEndian
        }
    }
}
