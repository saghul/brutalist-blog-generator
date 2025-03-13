import ArgumentParser

struct InitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new website project"
    )

    func run() throws {
        print("Initializing new website project...")
        // Add initialization logic here
    }
}
