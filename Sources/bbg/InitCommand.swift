import ArgumentParser

import BBGCore

struct InitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new blog"
    )

    func run() {
        print("Initializing new blog...")
        // TODO: Add initialization logic here
    }
}
