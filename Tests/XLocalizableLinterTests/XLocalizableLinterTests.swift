import XCTest
@testable import XLocalizableLinter

final class XLocalizableLinterTests: XCTestCase {
    func testExample() throws {
        let filePath = URL(string: #file)!
        let projectPath = "\(filePath.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent())/example/example.xcodeproj"

        let unusedKeys = try findUnusedLocalizableKeys(
            projectPath: projectPath,
            supportedLanguages: ["ja"]
        )
        XCTAssertTrue(unusedKeys.isEmpty)
    }

    func testExampleHasUnusedKey() throws {
        let filePath = URL(string: #file)!
        let projectPath = "\(filePath.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent())/exampleHasUnusedKey/exampleHasUnusedKey.xcodeproj"

        let unusedKeys = try findUnusedLocalizableKeys(
            projectPath: projectPath,
            supportedLanguages: ["ja"]
        )
        XCTAssertEqual(unusedKeys.sorted(), [
            "Hello, world!",
            "NSLocalizedString",
            "interpolation: int %lld",
            "interpolation: double %lf",
            "interpolation: str %@",
            "interpolation: date %@",
            "multi\n \"line\"\n  text",
            "localizedStringKey",
        ].sorted())
    }
}
