import ArgumentParser
import Foundation

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the website"
    )

    func run() throws {
        print("Building website...")

        do {
            let filePath = "README.md"

            // Parse document
            let document = try Document.parse(path: filePath)

            // Convert to HTML
            let html = document.toHtml()

            // Save to file
            let outputPath = filePath.replacingOccurrences(of: ".md", with: ".html")
            try html.write(toFile: outputPath, atomically: true, encoding: .utf8)

            print("Successfully generated HTML at: \(outputPath)")
        } catch {
            print("Error: \(error)")
            throw error
        }
    }
}
