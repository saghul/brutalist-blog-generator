import ArgumentParser
import Foundation

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the blog"
    )

    func run() throws {
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
            try processPost(document: document)
        }

        // Generate index
        let index = try Document.parse(path: "www/index.md")
        try processIndex(index: index, documents: documents)
    }

    private func processIndex(index: Document, documents: [Document]) throws {
        let outputDir = URL(fileURLWithPath: "build")

        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true, attributes: nil)
        let outputUrl = outputDir
            .appendingPathComponent("index.html")

        let html = index.toHtml()
        let context: [String : Any] = [
            "title": index.title,
            "content": html,
            "posts": documents.map { document in
                return [
                    "title": document.title,
                    "date": document.date,
                    "url": "posts/" + document.fileName,
                ]
            }
        ]
        let finalHtml = try renderIndex(context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }

    private func processPost(document: Document) throws {
        let outputDir = URL(fileURLWithPath: "build/posts")

        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true, attributes: nil)
        let outputUrl = outputDir
            .appendingPathComponent(document.fileName)

        let html = document.toHtml()
        let context = [
            "post": [
                "title": document.title,
                "date": document.date,
                "content": html
            ]
        ]
        let finalHtml = try renderPost(context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }
}
