import Foundation
import Markdown
import Yams

public struct Document {
    private let content: Markdown.Document
    private let metadata: DocumentMetadata?

    private init(content: Markdown.Document, metadata: DocumentMetadata? = nil) {
        self.content = content
        self.metadata = metadata
    }

    public static func parse(path: String) throws -> Document {
        let fileContent = try String(contentsOfFile: path, encoding: .utf8)

        // Split YAML front matter and content
        let components = splitFrontMatter(from: fileContent)

        // Parse the Markdown document
        let document = Markdown.Document(parsing: components.content)

        do {
            let metadata = try parseMetadata(components.yaml)
            return Document(content: document, metadata: metadata)
        } catch {
            // If YAML parsing fails, treat entire file as markdown without metadata
            return Document(content: document, metadata: nil)
        }
    }

    public func toHtml() -> String {
        return HTMLFormatter.format(content)
    }

    var title: String {
        return metadata?.title ?? ""
    }

    var date: String {
        return metadata?.date ?? ""
    }

    var slug: String {
        return metadata?.slug ?? ""
    }
}

struct DocumentMetadata {
    let title: String?
    let date: String?
    let slug: String?
}

func parseMetadata(_ yaml: String?) throws -> DocumentMetadata {
    let yaml = try Yams.load(yaml: yaml ?? "") as? [String: String]

    let title = yaml?["title"]
    let date = yaml?["date"]
    let slug = yaml?["slug"]

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
