import ArgumentParser

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the website"
    )

    func run() throws {
        print("Building website...")
        // Add build logic here
    }
}
