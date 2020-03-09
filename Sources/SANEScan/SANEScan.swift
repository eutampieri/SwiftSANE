import Foundation
import Socket

private func saneVersionCode(major: Int32, minor: Int32, build: Int32) -> Int32 {
return (  (((major) &   0xff) << 24)
 | (((minor) &   0xff) << 16)
 | (((build) & 0xffff) <<  0))
}

class SANEScan {
    private let socket: Socket
    private let username: String
    private let saneVersion: Int32?
    public var result: String
    init(address: String) throws {
        self.username = "swiftscan\(Int.random(in: 1000000...9999999))"
        
        try self.socket = Socket.create()
        try socket.connect(to: address, port: 6566)
        
        var request = try [
            SaneRpc.Init,
            SaneVersion(major: 1, minor: 0, build: 3),
            self.username
        ].saneEncode()
        try socket.write(from: request)
                
        var result = Data()
        let breads = try socket.read(into: &result)
        print("Read \(breads) bytes")
        saneVersion = 1
        self.result = result.base64EncodedString()
    }
    func listScanners() throws{
        var request = try [
            SaneRpc.GetDevices,
        ].saneEncode()
        try socket.write(from: request)
                
        var result = Data()
        let breads = try socket.read(into: &result)
        print("Read \(breads) bytes")
        self.result = result.base64EncodedString()
    }
}
