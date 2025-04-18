import Markdown

struct TitleDeleter: MarkupRewriter {
    mutating func visitHeading(_ heading: Heading) -> Markup? {
        guard heading.level > 1 else {
            return nil
        }

        return heading
    }
}


extension Markdown.Document {
    func getTitle() -> String? {
        guard let heading = children.first(where: { $0 is Heading }) as? Heading else {
            return nil
        }

        return heading.plainText
    }

    func deleteTitle() -> Markdown.Document {
        var rewriter = TitleDeleter()
        return rewriter.visit(self) as! Markdown.Document
    }
}
