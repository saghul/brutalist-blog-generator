import Foundation

protocol DirectoryMonitorDelegate {
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor)
}

class DirectoryMonitor {
    var delegate: DirectoryMonitorDelegate?

    private let queue =  DispatchQueue.main
    private let url: URL
    private var fileMonitors: [String: DispatchSource] = [:]

    init(url: URL) {
        self.url = url
    }

    func startMonitoring() {
        // Set up initial file monitors.
        updateFileMonitors()
    }

    private func updateFileMonitors() {
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) else {
            return
        }

        // Get all paths recursively.
        var currentPaths = Set<String>()
        // The root directory is not part of the enumerator, so we need to add it manually.
        currentPaths.insert(url.path)
        while let fileURL = enumerator.nextObject() as? URL {
            currentPaths.insert(fileURL.path)
        }

        // Remove monitors for files that no longer exist.
        let monitoredPaths = Set(fileMonitors.keys)
        let removedPaths = monitoredPaths.subtracting(currentPaths)

        for path in removedPaths {
            fileMonitors[path]?.cancel()
        }

        // Add monitors for new files.
        let newPaths = currentPaths.subtracting(monitoredPaths)
        for path in newPaths {
            let fd = open(path, O_EVTONLY)
            guard fd >= 0 else { continue }

            let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: [.write, .extend, .attrib], queue: queue)
            source.setEventHandler { [weak self] in
                guard let self = self else { return }
                print("File changed: \(path)")
                self.updateFileMonitors()
                self.delegate?.directoryMonitorDidObserveChange(directoryMonitor: self)
            }
            source.setCancelHandler { [weak self] in
                guard let self = self else { return }
                close(fd)
                self.fileMonitors.removeValue(forKey: path)
            }
            source.resume()

            fileMonitors[path] = source as? DispatchSource
        }
    }

    func stopMonitoring() {
        // Cancel all individual file monitors
        for monitor in fileMonitors.values {
            monitor.cancel()
        }
        fileMonitors.removeAll()
    }

    deinit {
        stopMonitoring()
    }
}
