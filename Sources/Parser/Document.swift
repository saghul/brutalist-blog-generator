import Foundation
import Markdown
import Yams

public enum DocumentError: Error {
    case invalidSlug(String)
}

public struct Document {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

    private let content: Markdown.Document
    private let metadata: DocumentMetadata

    private init(content: Markdown.Document, metadata: DocumentMetadata) {
        self.content = content
        self.metadata = metadata
    }

    public static func parse(path: String) throws -> Document {
        let fileContent = try String(contentsOfFile: path, encoding: .utf8)

        // Split YAML front matter and content
        let components = splitFrontMatter(from: fileContent)

        // Parse the Markdown document
        let document = Markdown.Document(parsing: components.content)

        // Parse metadata
        let metadata = try parseMetadata(components.yaml)

        return Document(content: document, metadata: metadata)
    }

    public func toHtml() -> String {
        return HTMLFormatter.format(content)
    }

    private func slugify(_ string: String) throws -> String {
        // Adapted from: https://github.com/twostraws/SwiftSlug

        var result: String? = nil
        if let latin = string.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: Document.slugSafeCharacters.inverted)
            result = urlComponents.filter { $0 != "" }.joined(separator: "-")
        }

        if let result = result {
            if result.count > 0 {
                return result
            }
        }

        throw DocumentError.invalidSlug(string)
    }

    var title: String {
        return metadata.title
    }

    var date: Date {
        return metadata.date
    }

    var slug: String {
        get throws {
            if metadata.slug.isEmpty {
                return try slugify(title)
            }

            return try slugify(metadata.slug)
        }
    }
}

struct DocumentMetadata {
    let title: String
    let date: Date
    let slug: String
}

func parseMetadata(_ yaml: String?) throws -> DocumentMetadata {
    let yaml = try Yams.load(yaml: yaml ?? "") as? [String: String]

    let title = yaml?["title"] ?? ""
    let slug = yaml?["slug"] ?? ""
    let dateStr = yaml?["date"] ?? ""
    let formatter = ISO8601DateFormatter()
    let date = formatter.date(from: dateStr) ?? Date()

    return DocumentMetadata(title: title, date: date, slug: slug)
}

func splitFrontMatter(from content: String) -> (yaml: String, content: String) {
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
