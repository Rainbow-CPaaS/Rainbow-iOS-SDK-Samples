#!/usr/bin/swift

import Foundation

extension String {
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        get {
            return (self as NSString).deletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).deletingPathExtension
        }
    }
    var pathComponents: [String] {
        get {
            return (self as NSString).pathComponents
        }
    }
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
    func appendingPathComponent(_ path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    var deletingPathExtension : String {
        get {
            (self as NSString).deletingPathExtension
        }
    }
    
    func matchesForRegex(_ regex: String) -> [String] {
      var result = [String]()
      do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = self as NSString
        if let match = regex.firstMatch(in: self, options: [], range: NSMakeRange(0, nsString.length)) {
          for i in 1..<match.numberOfRanges {
            result.append(nsString.substring(with: match.range(at: i)))
          }
        }
      } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
      }
      return result
    }
}

@discardableResult func shell(_ command: String) -> (String?, Int32) {
    let task = Process()

    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}

// check command line arguments
if CommandLine.arguments.count > 2 {
    print("Usage: \(CommandLine.arguments[0].lastPathComponent) [Rainbow_SDK_version]")
    exit(1)
}

let requiredSDK = CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : ""

let xcodebuildcmd = "/usr/bin/xcodebuild -project %@ -destination 'platform=iOS Simulator,name=iPhone 8,OS=13.2' -sdk iphonesimulator"

let directories = [
	"Rainbow-iOS-SDK-Sample-Background",
	"Rainbow-iOS-SDK-Sample-Channels",
	"Rainbow-iOS-SDK-Sample-Contacts",
	"Rainbow-iOS-SDK-Sample-FileSharing",
	"Rainbow-iOS-SDK-Sample-IM",
	"Rainbow-iOS-SDK-Sample-Login",
	"Rainbow-iOS-SDK-Sample-SFU",
	"Rainbow-iOS-SDK-Sample-Swift",
	"Rainbow-iOS-SDK-Sample-WebRTC"
]

var results : [(Bool, String)] = []

for dir in directories {
    // Sanity checks on the directory
    guard dir != "" && !dir.contains("/") && FileManager.default.fileExists(atPath: dir) else {
        let msg = "Invalid directory: '\(dir)'"
        results.append((false, msg))
        print("\(String(repeating: "*", count: 60))")
        print(msg)
        print("\(String(repeating: "*", count: 60))")
        print()
        continue
    }
    print("\(String(repeating: "*", count: 60))")
    print("Building: \(dir)")
    print("\(String(repeating: "*", count: 60))")
    
    let (xcodeprojFile, _) = shell("cd \(dir);  ls -d *.xcodeproj")
    if let xcodeprojFile = xcodeprojFile {
        let xcodeprojFile = xcodeprojFile.trimmingCharacters(in: .whitespacesAndNewlines)
        let projDir = xcodeprojFile.deletingPathExtension
        print ("XCode project dir : \(projDir)")
        print ("XCode project file: \(xcodeprojFile)")
        
        // Update cartfile
        let (cartfile, _) = shell("cd \(dir); cat \(projDir)/Cartfile")
        if let cartfile = cartfile {
            let version = cartfile.matchesForRegex("RainbowSDK.json\" == ([0-9\\.]+)")
            if version.count == 1 {
                if requiredSDK != "" {
                    if requiredSDK != version[0] {
                        let (newCartfile, _) = shell("cd \(dir); cat \(projDir)/Cartfile|sed 's/\(version[0])/\(requiredSDK)/'")
                        if let newCartfile = newCartfile {
                            let newVersion = newCartfile.matchesForRegex("RainbowSDK.json\" == ([0-9\\.]+)")
                            if newVersion.count == 1 {
                                print("Rainbow SDK version: \(newVersion[0])")
                                do {
                                    try newCartfile.write(to: URL(fileURLWithPath: "\(dir)/\(projDir)/Cartfile"), atomically: true, encoding: String.Encoding.utf8)
                                } catch {
                                    print("Failed to write Cartfile !")
                                    results.append((false, "Failed to write Cartfile for \(dir)"))
                                    continue
                                }
                            }
                        }
                    } else {
                        print("Rainbow SDK version: \(version[0])")
                    }
                } else {
                    print("Rainbow SDK version: \(version[0])")
                }
            }
        }
        print()
        
        // Remove previous build dir
        print("Cleaning build dir...\n")
        shell("rm -rf \(dir)/build")
        
        // Carthage
        print("Do carthage update...")
        let (carthageOut, _) = shell("cd \(dir)/\(projDir); carthage update")
        if let carthageOut = carthageOut {
            print(carthageOut)
        }
        
        // Build
        let buildcmd = String(format: xcodebuildcmd, xcodeprojFile)
        
        print("Building...")
        let (output, retCode) = shell("cd \(dir); \(buildcmd)")
        print("Return code=\(retCode)")
        if let output = output {
            if output.contains("** BUILD SUCCEEDED **") {
                print()
                print("[OK] \(dir)")
                results.append((true, "\(dir) build is OK"))
            } else {
                print(output)
                print("[NOK] \(dir)")
                results.append((false, "\(dir) built with errors !"))
            }
        }
    }
    print("\n")
}

print("\(String(repeating: "*", count: 60))\n")
print("RESULTS:\n")

var nbError = 0
for (result, msg) in results {
    print(msg)
    if !result {
        nbError += 1
    }
}
if nbError == 0 {
    print("\nAll build are OK !\n")
} else {
    print("\nThere were \(nbError) build(s) that didn't compile\n")
}


