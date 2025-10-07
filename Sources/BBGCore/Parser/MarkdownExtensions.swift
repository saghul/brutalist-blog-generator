import Markdown

struct CustomRewriter: MarkupRewriter {
    mutating func visitHeading(_ heading: Heading) -> Markup? {
        guard heading.level > 1 else {
            return nil
        }

        return heading
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Markup? {
        // Escape HTML entities in the code
        let escapedCode = escapeHTML(codeBlock.code)

        // Create a new code block with escaped content
        return CodeBlock(language: codeBlock.language, escapedCode)
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Markup? {
        // Escape HTML entities in inline code
        let escapedCode = escapeHTML(inlineCode.code)

        // Create new inline code with escaped content
        return InlineCode(escapedCode)
    }

    private func escapeHTML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}


extension Markdown.Document {
    func getTitle() -> String? {
        guard let heading = children.first(where: { $0 is Heading }) as? Heading else {
            return nil
        }

        return heading.plainText
    }
}
