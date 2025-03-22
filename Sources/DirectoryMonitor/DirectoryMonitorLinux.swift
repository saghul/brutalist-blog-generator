#if os(Linux)

import Foundation
#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#else
#error("Unsupported platform")
#endif

class DirectoryMonitor {
    var delegate: DirectoryMonitorDelegate?

    private let queue = DispatchQueue.main
    private let url: URL
    private var inotifyFd: Int32
    private var watchDescriptors: [Int32: String] = [:]
    private var isMonitoring = false
    private var monitoringSource: DispatchSourceRead?

    init(url: URL) {
        self.url = url
        self.inotifyFd = inotify_init()
        if inotifyFd == -1 {
            fatalError("Failed to initialize inotify")
        }
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        // Set up initial watches
        updateWatches()

        // Set up monitoring of inotify events
        monitoringSource = DispatchSource.makeReadSource(fileDescriptor: inotifyFd, queue: queue)
        monitoringSource?.setEventHandler { [weak self] in
            self?.processInotifyEvents()
        }
        monitoringSource?.resume()
    }

    private func updateWatches() {
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) else {
            return
        }

        // Get all paths recursively
        var currentPaths = Set<String>()
        currentPaths.insert(url.path)
        while let fileURL = enumerator.nextObject() as? URL {
            currentPaths.insert(fileURL.path)
        }

        // Remove watches for paths that no longer exist
        let watchedPaths = Set(watchDescriptors.values)
        let removedPaths = watchedPaths.subtracting(currentPaths)

        for path in removedPaths {
            if let wd = watchDescriptors.first(where: { $0.value == path })?.key {
                inotify_rm_watch(inotifyFd, wd)
                watchDescriptors.removeValue(forKey: wd)
            }
        }

        // Add watches for new paths
        let newPaths = currentPaths.subtracting(watchedPaths)
        for path in newPaths {
            let mask = UInt32(IN_MODIFY | IN_ATTRIB | IN_CREATE | IN_DELETE | IN_MOVE)
            let wd = inotify_add_watch(inotifyFd, path, mask)
            if wd >= 0 {
                watchDescriptors[wd] = path
            }
        }
    }

    private func processInotifyEvents() {
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)

        let readLength = read(inotifyFd, &buffer, bufferSize)
        guard readLength > 0 else { return }

        var offset = 0
        while offset < readLength {
            let event = buffer.withUnsafeBufferPointer { ptr in
                ptr.baseAddress!.withMemoryRebound(to: inotify_event.self, capacity: 1) { $0.pointee }
            }

            if event.mask != 0 {
                //print("Change detected in watch descriptor: \(event.wd)")
                updateWatches()
                delegate?.directoryMonitorDidObserveChange(path: watchDescriptors[event.wd] ?? "")
            }

            offset += MemoryLayout<inotify_event>.size + Int(event.len)
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false

        monitoringSource?.cancel()
        monitoringSource = nil

        // Remove all watches
        for wd in watchDescriptors.keys {
            inotify_rm_watch(inotifyFd, wd)
        }
        watchDescriptors.removeAll()
    }

    deinit {
        stopMonitoring()
        close(inotifyFd)
    }
}

#endif
