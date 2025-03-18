import Foundation
import Stencil

struct TemplateEngine {
    private let environment: Environment
    private let loader: DictionaryLoader

    init(templates: [String: String]) {
        loader = DictionaryLoader(templates: templates)
        environment = Environment(loader: loader)
    }

    func renderTemplate(name: String, context: [String: Any]) throws -> String {
        let template = try environment.loadTemplate(name: name)
        return try template.render(context)
    }
}
