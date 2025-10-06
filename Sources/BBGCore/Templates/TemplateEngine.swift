import Foundation
import Mustache

struct TemplateEngine {
    private var library: MustacheLibrary

    init(templates: [String: String]) {
        library = MustacheLibrary()

        // Register all templates in the library
        for (name, content) in templates {
            try! library.register(content, named: name)
        }
    }

    func renderTemplate(name: String, context: [String: Any]) throws -> String {
        guard let output = library.render(context, withTemplate: name) else {
            throw TemplateError.renderFailed(name: name)
        }
        return output
    }
}

enum TemplateError: Error {
    case renderFailed(name: String)
}
