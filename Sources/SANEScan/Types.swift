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
}
struct SaneDevice {
    var name: String
    var vendor: ScannerVendor
    var model: String
    var type: ScannerType
}

struct SaneDeviceList {
    var status: SaneStatus
    var device_list: [SaneRpc]
}

struct SaneVersion {
    var major: Int8
    var minor: Int8
    var build: Int
}

