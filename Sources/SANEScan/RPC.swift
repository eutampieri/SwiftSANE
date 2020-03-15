//
//  SANERpc.swift
//  SANEScan
//
//  Created by Eugenio Tampieri on 06/03/2020.
//

import Foundation

/// Most SANE operations return a value of type SANE_Status to indicate whether the completion status of the operation. If an operation completes successfully, SANE_STATUS_GOOD is returned. In case of an error, a value is returned that indicates the nature of the problem.
enum SaneStatus: Int32, Error {
    /// Operation completed succesfully.
    case OK = 0
    /// Operation is not supported
    case Unsupported
    /// Operation was cancelled.
    case Cancelled
    /// Device is busy---retry later.
    case DeviceBusy
    /// Data or argument is invalid.
    case InvalidOption
    /// No more data available (end-of-file).
    case EOF
    /// Document feeder jammed.
    case FeederJammed
    /// Document feeder out of documents.
    case FeederOutOfDocs
    /// Scanner cover is open.
    case CoverOpen
    /// Error during device I/O.
    case IOError
    /// Out of memory.
    case OutOfMemory
    /// Access to resource has been denied.
    case AccessDenied
}
extension SaneDecoder {
    func extract() -> SaneStatus {
        return SaneStatus(rawValue: Int32(self.extract())) ?? SaneStatus.Unsupported
    }
}

enum SaneRpc: Int32 {
    case Init = 0
    case GetDevices
    case Open
    case Close
    case GetOptionDescriptors
    case ControlOption
    case GetParameters
    case Start
    case Cancel
    case Authorize
    case Exit
}
