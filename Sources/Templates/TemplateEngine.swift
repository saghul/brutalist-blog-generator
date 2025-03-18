import Foundation
import Stencil

private struct Engine {
    private let environment: Environment
    private let loader: DictionaryLoader

    public init() {
        loader = DictionaryLoader(templates: [
            "post": String(decoding: Data(PackageResources.post_html), as: UTF8.self)
        ])
        environment = Environment(loader: loader)
    }

    public func renderPost(context: [String: Any]) throws -> String {
        let template = try environment.loadTemplate(name: "post")
        return try template.render(context)
    }
}

// TODO: figure out the concurrency story here.
nonisolated(unsafe) private let engine = Engine()

public func renderPost(context: [String: Any]) throws -> String {
    return try engine.renderPost(context: context)
}
