import XCTest
@testable import SANEScan

final class SANEScanTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        do {
            let a = try SANEScan(address: "192.168.1.9")
            let list = try a.listScanners()
            let handle = try a.openDevice(name: list[0].name)
            print("\(try a.getOptionDescriptors(for: handle))\n\naaaaaaaaa\n\n")
            
            print("\(try a.controlOption(handle: handle, option: 2, action: 0, type: .Fixed, value: 10.1))\n\n")
            try a.getParameters(for: handle)
            try a.closeDevice(handle: handle)
        } catch {
            print("\(error)")
            XCTFail()
            print("ERR")
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
