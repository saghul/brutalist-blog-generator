public protocol DirectoryMonitorDelegate {
    func directoryMonitorDidObserveChange(path: String)
}
