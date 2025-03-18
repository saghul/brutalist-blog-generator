import Foundation
import Stencil

private struct Engine {
    private let environment: Environment
    private let loader: DictionaryLoader

    public init() {
        loader = DictionaryLoader(templates: [
            "index": String(decoding: Data(PackageResources.index_html), as: UTF8.self),
            "post": String(decoding: Data(PackageResources.post_html), as: UTF8.self),
        ])
        environment = Environment(loader: loader)
    }

    private func renderTemplate(name: String, context: [String: Any]) throws -> String {
        let template = try environment.loadTemplate(name: name)
        return try template.render(context)
    }

    public func renderIndex(context: [String: Any]) throws -> String {
        return try renderTemplate(name: "index", context: context)
    }

    public func renderPost(context: [String: Any]) throws -> String {
        return try renderTemplate(name: "post", context: context)
    }
}

// TODO: figure out the concurrency story here.
nonisolated(unsafe) private let engine = Engine()

public func renderIndex(context: [String: Any]) throws -> String {
    return try engine.renderIndex(context: context)
}

public func renderPost(context: [String: Any]) throws -> String {
    return try engine.renderPost(context: context)
}
