import Foundation
import Markdown

public enum DocumentError: Error {
    case missingTitle
    case invalidSlug
}

public struct Document {
    private let content: Markdown.Document
    private let metadata: DocumentMetadata
    private let _title: String
    private let _slug: String

    private init(content: Markdown.Document, metadata: DocumentMetadata, title: String, slug: String) {
        self.content = content
        self.metadata = metadata
        self._title = title
        self._slug = slug
    }

    public static func parse(path: String) throws -> Document {
        let fileContent = try String(contentsOfFile: path, encoding: .utf8)

        // Split YAML front matter and content
        let components = splitFrontMatter(from: fileContent)

        // Parse the Markdown document
        let document = Markdown.Document(parsing: components.content)

        // Parse metadata
        let metadata = try DocumentMetadata.parse(data: components.yaml)

        // Extract title
        let title = metadata.title ?? document.getTitle() ?? ""
        guard !title.isEmpty else {
            throw DocumentError.missingTitle
        }

        // Extract slug
        let slug = slugify(metadata.slug ?? title)
        guard let validSlug = slug else {
            throw DocumentError.invalidSlug
        }

        return Document(content: document.deleteTitle(), metadata: metadata, title: title, slug: validSlug)
    }

    public func toHtml() -> String {
        return HTMLFormatter.format(content)
    }

    var title: String {
        return self._title
    }

    var date: Date {
        return metadata.date
    }

    var slug: String {
        return self._slug
    }
}

// Utilities
extension Document {
    static func splitFrontMatter(from content: String) -> (yaml: String, content: String) {
        let pattern = "^---\\n([\\s\\S]*?)\\n---\\n([\\s\\S]*$)"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
            let match = regex.firstMatch(
                in: content,
                options: [],
                range: NSRange(content.startIndex..., in: content)
            ) else {
            return ("", content)
        }

        let yamlRange = Range(match.range(at: 1), in: content)!
        let contentRange = Range(match.range(at: 2), in: content)!

        return (
            String(content[yamlRange]).trimmingCharacters(in: .whitespacesAndNewlines),
            String(content[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

    static func slugify(_ string: String) -> String? {
        // Adapted from: https://github.com/twostraws/SwiftSlug

        var result: String? = nil
        if let latin = string.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: slugSafeCharacters.inverted)
            result = urlComponents.filter { $0 != "" }.joined(separator: "-")
        }

        guard let result = result, !result.isEmpty else {
            return nil
        }

        return result
    }

}
