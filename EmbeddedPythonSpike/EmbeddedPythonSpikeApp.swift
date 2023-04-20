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
        // Initialize the Python runtime early in the app
        if  let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil),
            let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil)
        {
            setenv("PYTHONHOME", stdLibPath, 1)
            setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath)", 1)
            Py_Initialize()
        }
    }
    
    // Simple example of loading Python modules into the runtime
    // and accessing Python object members in Swift
    func printPythonInfo() {
        let sys = Python.import("sys")
        
        print("Python Version: \(sys.version_info.major).\(sys.version_info.minor)")
        print("Python Encoding: \(sys.getdefaultencoding().upper())")
        print("Python Path: \(sys.path)")
        
        _ = Python.import("math") // verifies `lib-dynload` is found and signed successfully
    }
}

@main
struct EmbeddedPythonSpikeApp: App {
    @StateObject var embeddedPython = EmbeddedPython()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    embeddedPython.printPythonInfo()
                }
        }
    }
}
