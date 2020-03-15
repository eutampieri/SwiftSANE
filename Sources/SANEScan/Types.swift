//
//  Types.swift
//  SANEScan
//
//  Created by Eugenio Tampieri on 08/03/2020.
//

import Foundation

enum ScannerVendor {
    case AGFA
    case Abaton
    case Acer
    case Apple
    case Artec
    case Avision
    case CANON
    case Connectix
    case Epson
    case Fujitsu
    case HewlettPackard
    case IBM
    case Kodak
    case Lexmark
    case Logitech
    case Microtek
    case Minolta
    case Mitsubishi
    case Mustek
    case NEC
    case Nikon
    case Plustek
    case Polaroid
    case Relisys
    case Ricoh
    case Sharp
    case Siemens
    case Tamarack
    case UMAX
    case NoName
    case Other(String)
}
extension SaneDecoder {
    func extract() throws -> ScannerVendor {
        let raw: String = try self.extract()
        switch raw {
        case "AGFA":
            return .AGFA
        case "Abaton":
            return .Abaton
        case "Acer":
            return .Acer
        case "Apple":
            return .Apple
        case "Artec":
            return .Artec
        case "Avision":
            return .Avision
        case "CANON":
            return .CANON
        case "Connectix":
            return .Connectix
        case "Epson":
            return .Epson
        case "Fujitsu":
            return .Fujitsu
        case "HewlettPackard":
            return .HewlettPackard
        case "HP":
            return .HewlettPackard
        case "IBM":
            return .IBM
        case "Kodak":
            return .Kodak
        case "Lexmark":
            return .Lexmark
        case "Logitech":
            return.Logitech
        case "Microtek":
            return .Microtek
        case "Minolta":
            return .Minolta
        case "Mitsubishi":
            return .Mitsubishi
        case "Mustek":
            return .Mustek
        case "NEC":
            return .NEC
        case "Nikon":
            return .Nikon
        case "Plustek":
            return .Plustek
        case "Polaroid":
            return .Polaroid
        case "Relisys":
            return .Relisys
        case "Ricoh":
            return .Ricoh
        case "Sharp":
            return .Sharp
        case "Siemens":
            return .Siemens
        case "Tamarack":
            return .Tamarack
        case "UMAX":
            return .UMAX
        case "NoName":
            return .NoName
        default:
            return .Other(raw)
        }
    }
}
enum ScannerType {
    case FilmScanner
    case FlatbedScanner
    case FrameGrabber
    case HandeldScanner
    case MFP
    case SheetfedScanner
    case StillCamera
    case VideoCamera
    case Virtual
    case Other(String)
}
extension SaneDecoder {
    func extract() throws -> ScannerType {
        let raw: String = try self.extract()
        switch raw {
        case "film scanner":
            return .FilmScanner
        case "flatbed scanner":
            return .FlatbedScanner
        case "frame grabber":
            return .FrameGrabber
        case "handheld scanner":
            return .HandeldScanner
        case "MFP":
            return .MFP
        case "sheetfed scanner":
            return .SheetfedScanner
        case "still camera":
            return .StillCamera
        case "video camera":
            return .VideoCamera
        case "virtual":
            return .Virtual
        default:
            return .Other(raw)
        }
    }
}

struct SaneDevice {
    var name: String
    var vendor: ScannerVendor
    var model: String
    var type: ScannerType
}

struct SaneVersion {
    var major: Int8
    var minor: Int8
    var build: Int
}
extension SaneDecoder{
    func extract() -> SaneVersion {
        let code: Int = self.extract()
        return SaneVersion(major: Int8((code >> 24) & 0xFF), minor: Int8((code >> 16) & 0xFF), build: ((code >> 0) & 0xFFFF))
    }
}

enum SaneType: Int {
    case Bool
    case Int
    case Fixed
    case String
    case Button
    case Group
}
extension SaneDecoder{
    func extract() throws -> SaneType {
        let code: Int = self.extract()
        if let result = SaneType(rawValue: code) {
            return result
        }
        throw CodecError.UnknownType
    }
}

enum SaneUnit: Int {
    case None
    case Pixel
    case Bit
    case Mm
    case Dpi
    case Percent
    case Microsecond
}
extension SaneDecoder{
    func extract() throws -> SaneUnit {
        let code: Int = self.extract()
        if let result = SaneUnit(rawValue: code) {
            return result
        }
        throw CodecError.UnknownType
    }
}

enum SaneOptionCapability {
    case SoftwareSelectable
    case HardwareSelectable
    case SoftwareDetectable
    case Emulated
    case Automatic
    case Inactive
    case Advanced
}
extension SaneDecoder{
    func extract() -> [SaneOptionCapability] {
        let raw: Int = self.extract()
        var result: [SaneOptionCapability] = []
        if raw & 1 != 0 {
            result.append(.SoftwareSelectable)
        }
        if raw & 2 != 0 {
            result.append(.HardwareSelectable)
        }
        if raw & 4 != 0 {
            result.append(.SoftwareDetectable)
        }
        if raw & 8 != 0 {
            result.append(.Emulated)
        }
        if raw & 16 != 0 {
            result.append(.Automatic)
        }
        if raw & 32 != 0 {
            result.append(.Inactive)
        }
        if raw & 64 != 0 {
            result.append(.Advanced)
        }
        return result
    }
}

enum SaneConstraint {
    case None
    case Range(Float, Float, Float)
    case WordList([Float])
    case StringList([String])
}
extension SaneDecoder{
    func extract() throws -> SaneConstraint {
        let code: Int = self.extract()
        switch code {
        case 0:
            return .None
        case 1:
            return .Range(Float(self.extract()), Float(self.extract()), Float(self.extract()))
        case 2:
            var list: [Float] = []
            for _ in 0..<self.extract() {
                list.append(Float(self.extract()))
            }
            return .WordList(list)
        case 3:
            var list: [String] = []
            for _ in 0..<self.extract() {
                list.append(try self.extract())
            }
            let _ = list.popLast()
            return .StringList(list)
        default:
            throw CodecError.UnknownType
        }
    }
}

struct SaneOption {
    var name: String
    var title: String
    var description: String
    var type: SaneType
    var unit: SaneUnit
    var size: Int
    var capabilities: [SaneOptionCapability]
    var constraint: SaneConstraint
}
extension SaneDecoder{
    func extract() throws -> SaneOption {
        var opt = SaneOption(name: try self.extract(), title: try self.extract(), description: try self.extract(), type: try self.extract(), unit: try self.extract(), size: self.extract(), capabilities: self.extract(), constraint: try self.extract())
        if opt.type == .Fixed {
            switch opt.constraint {
            case let .Range(a, b, c):
                opt.constraint = .Range(a.fromWord(), b.fromWord(), c.fromWord())
            case let .WordList(a):
                var b: [Float] = []
                for c in a {
                    b.append(c.fromWord())
                }
                opt.constraint = .WordList(b)
            default:
                break
            }
        }
        return opt
    }
}
