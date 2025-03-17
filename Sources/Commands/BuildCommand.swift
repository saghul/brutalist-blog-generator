import ArgumentParser
import Foundation

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the website"
    )

    func run() {
        print("Building website...")

        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: "www/posts")

        if let enumerator = fileManager.enumerator(atPath: directoryURL.path) {
            while let filePath = enumerator.nextObject() as? String {
                if filePath.hasSuffix(".md") {
                    let fullPathUrl = directoryURL.appendingPathComponent(filePath)
                    print("Found file: \(fullPathUrl.path)")
                    do {
                        try processFile(at: fullPathUrl.path)
                    } catch {
                        print("Failed to process file: \(fullPathUrl.path)")
                        print(error)
                    }
                }
            }
        }
    }

    private func processFile(at path: String) throws {
        let document = try Document.parse(path: path)
        print("Title: \(document.title)")
        print("Date: \(document.date)")
        print("Slug: \(document.slug)")

        let directoryURL = URL(fileURLWithPath: "build")

        let calendar = Calendar.current
        let year = calendar.component(.year, from: document.date)
        let month = calendar.component(.month, from: document.date)
        let outputDirUrl = directoryURL
            .appendingPathComponent(String(format: "%04d", year))
            .appendingPathComponent(String(format: "%02d", month))
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDirUrl, withIntermediateDirectories: true, attributes: nil)
        let outputUrl = outputDirUrl
            .appendingPathComponent(document.slug)
            .appendingPathExtension("html")

        let html = document.toHtml()
        try html.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }
}
