import ArgumentParser
import Foundation

import BBGCore

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the blog"
    )

    @Flag(name: .long, help: "Watch for changes and rebuild automatically")
    var watch: Bool = false

    private var builder: SiteBuilder!

    mutating func run() throws {
        builder = SiteBuilder()
        try builder.build()

        if watch {
            #if os(macOS) || os(Linux)
            let watcher = DirectoryMonitor(url: URL(fileURLWithPath: builder.config.srcDir))
            watcher.delegate = self
            watcher.startMonitoring()
            print("Watching for changes in \(builder.config.srcDir)...")
            dispatchMain()
            #else
            print("Watching is not supported on this platform")
            Foundation.exit(1)
            #endif
        }
    }
}

extension BuildCommand: DirectoryMonitorDelegate {
    func directoryMonitorDidObserveChange(path: String) {
        do {
            print("Changes detected, rebuilding...")
            try builder.build()
        } catch {
            print("Error rebuilding: \(error)")
        }
    }
}
