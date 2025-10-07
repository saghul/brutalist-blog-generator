import ArgumentParser
import Foundation

import BBGCore

struct ServeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "serve",
        abstract: "Serve the blog locally and watch for changes"
    )

    @Option(name: .long)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 3000

    private var builder: SiteBuilder!

    mutating func run() async throws {
        builder = SiteBuilder(devSiteUrl: "http://\(hostname):\(port)")
        try builder.build()

        #if os(macOS) || os(Linux)
        let watcher = DirectoryMonitor(url: URL(fileURLWithPath: builder.config.srcDir))
        watcher.delegate = self
        watcher.startMonitoring()
        print("Watching for changes in \(builder.config.srcDir)...")
        #else
        print("Watching is not supported on this platform")
        #endif

        let server = SimpleWebServer(
            hostname: hostname,
            port: port,
            path: builder.config.outputDir
        )

        try await server.run()
    }
}

extension ServeCommand: DirectoryMonitorDelegate {
    func directoryMonitorDidObserveChange(path: String) {
        do {
            print("Changes detected, rebuilding...")
            try builder.build()
        } catch {
            print("Error rebuilding: \(error)")
        }
    }
}
