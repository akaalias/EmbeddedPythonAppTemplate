//
//  EmbeddedPythonSpikeApp.swift
//  EmbeddedPythonSpike
//
//  Created by Alexis Rondeau on 20.04.23.
//

import SwiftUI
import Python
import PythonKit

class EmbeddedPython: ObservableObject {
    init() {
        
        // Copy stuff over
        copyBundleFolderToDocumentsFolder(bundleFolderName: "python-stdlib")

        // Initialize the Python runtime early in the app
        let stdLibPath = getDocumentsDirectory().appending(path: "python-stdlib")
        let libDynloadPath = stdLibPath.appending(path: "lib-dynload")
        
        setenv("PYTHONHOME", stdLibPath.path(), 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath)", 1)
        Py_Initialize()
    }
        
    func resourceURL(to path: String) -> URL? {
        return URL(string: path, relativeTo: Bundle.main.resourceURL)
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func copyBundleFolderToDocumentsFolder(bundleFolderName: String) {

        let targetFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = targetFolderURL!.appendingPathComponent(bundleFolderName)
        
        guard let sourceFolderURL = resourceURL(to: bundleFolderName) else  {
            print("Could not find folder \(bundleFolderName) in Bundle")
            return
        }

        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: sourceFolderURL, to: destURL)
        } catch {
            print("Unable to copy folder \(bundleFolderName) from \(sourceFolderURL) to \(destURL)")
            print("Error: \(error)")
        }
    }
    
    // Simple example of loading Python modules into the runtime
    // and accessing Python object members in Swift
    func getPythonInfo() -> String {
        let sys = Python.import("sys")
        var output = ""
        output += "Python Version: \(sys.version_info.major).\(sys.version_info.minor)"
        output += "Python Encoding: \(sys.getdefaultencoding().upper())"
        output += "Python Path: \(sys.path)"
        _ = Python.import("math") // verifies `lib-dynload` is found and signed successfully
        
        return output
    }
}

@main
struct EmbeddedPythonSpikeApp: App {
    @StateObject var embeddedPython = EmbeddedPython()
    @State var info = ""
    
    var body: some Scene {
        WindowGroup {
            VStack {
                Text(self.info)
                    .multilineTextAlignment(.leading)
                    .font(.body)
            }
            .padding()
            .onAppear {
                self.info = embeddedPython.getPythonInfo()
            }
        }
    }
}
