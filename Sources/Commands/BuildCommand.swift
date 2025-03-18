import ArgumentParser
import Foundation

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the website"
    )

    func run() throws {
        print("Building website...")

        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: "www/posts")
        var documents: [Document] = []

        if let enumerator = fileManager.enumerator(atPath: directoryURL.path) {
            while let filePath = enumerator.nextObject() as? String {
                if filePath.hasSuffix(".md") {
                    let fullPathUrl = directoryURL.appendingPathComponent(filePath)
                    print("Found file: \(fullPathUrl.path)")
                    do {
                        let document = try Document.parse(path: fullPathUrl.path)
                        documents.append(document)
                    } catch {
                        print("Failed to process file: \(fullPathUrl.path)")
                        throw error
                    }
                }
            }
        }

        // Sort documents by date
        documents.sort { $0.date > $1.date }

        // Process each document
        for document in documents {
            try processDocument(document: document)
        }
    }

    private func processDocument(document: Document) throws {
        print("Title: \(document.title)")
        print("Date: \(document.date)")
        print("Slug: \(document.slug)")

        let outputDir = URL(fileURLWithPath: "build")

        let calendar = Calendar.current
        let year = calendar.component(.year, from: document.date)
        let month = calendar.component(.month, from: document.date)
        let fileName = String(format: "%04d-%02d-%@.html", year, month, document.slug)
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true, attributes: nil)
        let outputUrl = outputDir
            .appendingPathComponent(fileName)

        let html = document.toHtml()
        try html.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }
}
