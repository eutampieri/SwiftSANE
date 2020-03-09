import XCTest
@testable import SANEScan

final class SANEScanTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        do {
            /*let a = try SANEScan(address: "192.168.1.9")
            try a.listScanners()
            print("aaa \(a.result) bbb")
            print("PROVA")*/
            let encoded = try ["Ciao", 1].saneEncode()
            try print("\(["String", 1].getLength(from: encoded))")
        } catch {
            XCTFail()
            print("ERR")
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
