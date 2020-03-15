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

/// https://forums.swift.org/t/convert-uint8-to-int/30117/12
extension FixedWidthInteger {
  init<I>(littleEndianBytes iterator: inout I)
  where I: IteratorProtocol, I.Element == UInt8 {
    self = stride(from: 0, to: Self.bitWidth, by: 8).reduce(into: 0) {
      $0 |= Self(truncatingIfNeeded: iterator.next()!) &<< $1
    }
  }
  
  init<C>(littleEndianBytes bytes: C) where C: Collection, C.Element == UInt8 {
    precondition(bytes.count == (Self.bitWidth+7)/8)
    var iter = bytes.makeIterator()
    self.init(littleEndianBytes: &iter)
  }
}

/// A class that parses the message and consumes it doing this
class SaneDecoder {
    var raw_data: Data
    init(with data: Data) {
        raw_data = data
    }
    func discard(length: Int) {
        if raw_data.count <= length {
            raw_data = Data()
        } else {
            raw_data = raw_data.advanced(by: length)
        }
    }
    func extract() -> Int {
        let INT_LENGTH = 4
        let chunk = raw_data.subdata(in: 0..<INT_LENGTH)
        let result = Int32(littleEndianBytes: chunk.reversed())
        self.discard(length: INT_LENGTH)
        return Int(result)
    }
    
    func extract() throws -> String {
        let length: Int = self.extract()
        guard length > 0 else {
            return ""
        }
        let data = raw_data.subdata(in: 0..<length-1)
        guard let x = String(data: data, encoding: .ascii) else {
            throw CodecError.InvalidString
        }
        discard(length: length)
        return x
    }
    
    /*func extract() -> Float {
        let raw: Int = self.extract()
        return roundf(Float(raw) / Float(1 << 16))
    }*/
}

/*extension Array: SaneDecodable where Element == SaneDecodable {
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

*/
extension Float {
    /*func from(word: Int) -> Float {
        return Float.from(word: Float(word))
    }*/
    func fromWord() -> Float {
        roundf(self / Float(1 << 16))
    }
}
