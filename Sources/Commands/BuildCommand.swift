import ArgumentParser
import Foundation

struct BuildCommand: ParsableCommand, DirectoryMonitorDelegate {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the blog"
    )

    @Flag(name: .long, help: "Watch for changes and rebuild automatically")
    var watch: Bool = false

    func run() throws {
        let builder = SiteBuilder()
        try builder.build()

        if watch {
            let watcher = DirectoryMonitor(url: URL(fileURLWithPath: builder.config.srcDir))
            watcher.delegate = self
            watcher.startMonitoring()

            print("Watching for changes in \(builder.config.srcDir)...")
            dispatchMain()
        }
    }

    // Delegate method for DirectoryMonitor
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        do {
            print("Changes detected, rebuilding...")
            let builder = SiteBuilder()
            try builder.build()
        } catch {
            print("Error rebuilding: \(error)")
        }
    }
}
