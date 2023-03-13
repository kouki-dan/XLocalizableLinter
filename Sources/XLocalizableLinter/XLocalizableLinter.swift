
import ArgumentParser
import RegexBuilder
import Foundation

@main
struct XLocalizableLinter: ParsableCommand {

    @Argument(help: "The project path")
    var projectPath: String

    mutating func run() throws {
        let projectAbsolutePath = "\(FileManager.default.currentDirectoryPath)/\(projectPath)"
        let pbxproj = try String(contentsOfFile: projectAbsolutePath + "/project.pbxproj", encoding: .utf8)

        let supportedLanguages = getSupportedLanguages(pbxproj: pbxproj)

        let unusedKeys = try findUnusedLocalizableKeys(projectPath: projectAbsolutePath, supportedLanguages: supportedLanguages)

        if unusedKeys.isEmpty {
            print("All keys are used in a .strings file")
        } else {
            print("Unused keys")
            unusedKeys.forEach {
                print("- \($0)")
            }
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "There are unused keys in a .strings file"])
        }
    }
}

func getSupportedLanguages(pbxproj: String) -> [String] {
    var supportedLanguages: [String] = []
    var isInKnownRegions = false
    pbxproj.enumerateLines { line, stop in
        if line.contains("knownRegions = (") {
            isInKnownRegions = true
            return
        }
        if isInKnownRegions {
            if line.contains(")") {
                stop = true
                return
            }
            let language = String(line.trimmingCharacters(in: .whitespaces).dropLast(1))
            supportedLanguages.append(
                language
            )
        }
    }
    return supportedLanguages
}

func findUnusedLocalizableKeys(projectPath: String, supportedLanguages: [String]) throws -> [String] {
    let tmpDir = "tmp"
    defer {
        try? FileManager.default.removeItem(atPath: tmpDir)
    }

    let xcodeprojName = String(projectPath.split(separator: "/").last!)
    let projectRoot = String(projectPath.dropLast(xcodeprojName.count))

    try? FileManager.default.createDirectory(atPath: tmpDir, withIntermediateDirectories: true)

    try FileManager.default.copyItem(atPath: projectRoot, toPath: "\(tmpDir)/project")

    var keysInStrings: Set<String> = []
    let enumerator = FileManager.default.enumerator(atPath: "\(tmpDir)/project")
    while let element = enumerator?.nextObject() as? String {
        guard element.hasSuffix(".strings") else { continue }
        let filePath = "\(tmpDir)/project/\(element)"
        keysInStrings.formUnion(
            try findKeysInStrings(atPath: filePath)
        )
        // reset .strings file for xliff export
        try "".write(toFile: filePath, atomically: true, encoding: .utf8)
    }

    try generateXliff(
        projectPath: "\(tmpDir)/project/\(xcodeprojName)",
        outputPath: "\(tmpDir)/xliff",
        supportedLanguages: supportedLanguages
    )

    // All files have same ids in a xliff file because the contents of localized .strings file are empty.
    // It's ok to use any language in supported languages.
    let targetLanguage = supportedLanguages.first!
    let keysInSourceCode = try findIdsInXliff(atPath: "\(tmpDir)/xliff/\(targetLanguage).xcloc/Localized Contents/\(targetLanguage).xliff")

    let unusedKeys = keysInStrings.subtracting(keysInSourceCode)

    return Array(unusedKeys)
}

func findKeysInStrings(atPath path: String) throws -> Set<String> {
    let content = try String(contentsOfFile: path, encoding: .utf8)
    return findKeysInStrings(fromString: content)
}

func findKeysInStrings(fromString content: String) -> Set<String> {
    var keysInStrings: Set<String> = []

    var isInKey = false
    var isInValue = false
    var isInComment = false
    var previousChar: Character?
    var escaping = false
    var key = ""
    content.enumerateLines(invoking: { line, _ in
        previousChar = nil
        for char in line {
            defer {
                previousChar = char
            }
            if isInComment {
                if previousChar == "*", char == "/" {
                    // end of multiline comment
                    isInComment = false
                    previousChar = nil
                } else {
                    previousChar = nil
                }
                continue
            }
            if !isInKey || !isInValue {
                if previousChar == "/", char == "/" {
                    break
                }
                if previousChar == "/", char == "*" {
                    // start of multiline comment
                    isInComment = true
                    continue
                }
            }
            if escaping {
                escaping = false
                if char == "n" {
                    key.append("\n")
                    continue
                }
            } else {
                // ignore for values
                if isInValue {
                    if char == ";" {
                        isInValue = false
                        continue
                    } else {
                        continue
                    }
                }

                if !isInKey {
                    if char == "\"" {
                        isInKey = true
                    }
                    continue
                }
                if isInKey, char == "\"" {
                    keysInStrings.insert(key)
                    key = ""
                    isInKey = false
                    isInValue = true
                    continue
                }

                if char == "\\" {
                    escaping = true
                    continue
                }
            }
            key.append(String(char))
        }
        if isInKey {
            key.append("\n")
        }
    })

    return keysInStrings
}

func generateXliff(projectPath: String, outputPath: String, supportedLanguages: [String]) throws {
    let command = "xcodebuild -exportLocalizations -project \(projectPath) -localizationPath \(outputPath) " + supportedLanguages.map { "-exportLanguage \($0)" }.joined(separator: " ")

    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()

    _ = try pipe.fileHandleForReading.readToEnd()

    if task.terminationStatus != 0 {
        throw NSError(domain: "", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to generate xliff file in xcodebuild command"])
    }
}

func findIdsInXliff(atPath path: String) throws -> Set<String> {
    let content = try String(contentsOfFile: path, encoding: .utf8)
    return findIdsInXliff(fromString: content)
}

func findIdsInXliff(fromString content: String) -> Set<String> {
    class XliffParserDelegate: NSObject, XMLParserDelegate {
        var localizedKeys: Set<String> = []

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            guard elementName == "trans-unit" else { return }
            let localizedKey = attributeDict["id"]!
            localizedKeys.insert(localizedKey)
        }
    }

    let xliffParserDelegate = XliffParserDelegate()
    let parser = XMLParser(data: content.data(using: .utf8)!)
    parser.delegate = xliffParserDelegate
    parser.parse()
    return xliffParserDelegate.localizedKeys
}
