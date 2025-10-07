import ArgumentParser
import Foundation

#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import BBGCore

struct NewCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "new",
        abstract: "Create a new blog post"
    )

    mutating func run() throws {
        // Load config to get source directory
        let config = Config.load(from: "config.yml")
        let postsDir = "\(config.srcDir)/posts"

        // Prompt for title
        let title = promptForInput("Enter post title: ", required: true)

        // Prompt for date
        let dateDefault = getCurrentDateISO8601()
        let dateInput = promptForInput("Enter post date (YYYY-MM-DD) [\(formatDateForDisplay(dateDefault))]: ", defaultValue: dateDefault)
        let date = parseDateInput(dateInput) ?? dateDefault

        // Prompt for slug
        let computedSlug = BBGCore.Document.slugify(title) ?? "post"
        let slug = promptForInput("Enter slug [\(computedSlug)]: ", defaultValue: computedSlug)

        // Create file path
        let filePath = "\(postsDir)/\(slug).md"

        // Check if file already exists
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("Error: File already exists at \(filePath)")
            throw ExitCode.failure
        }

        // Create posts directory if it doesn't exist
        try fileManager.createDirectory(atPath: postsDir, withIntermediateDirectories: true)

        // Generate file content
        let content = """
        ---
        date: "\(date)"
        slug: "\(slug)"
        ---

        # \(title)

        Write your content here...

        """

        // Write file
        try content.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        print("Created: \(filePath)")

        // Prompt to open in editor
        let shouldEdit = promptForConfirmation("Open in editor?", defaultYes: true)
        if shouldEdit {
            launchEditor(filePath: filePath)
        }
    }

    // MARK: - Helper Functions

    private func promptForInput(_ prompt: String, defaultValue: String? = nil, required: Bool = false) -> String {
        while true {
            print(prompt, terminator: "")
            guard let input = readLine() else {
                if let defaultValue = defaultValue {
                    return defaultValue
                }
                continue
            }

            let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                if let defaultValue = defaultValue {
                    return defaultValue
                }
                if required {
                    print("This field is required.")
                    continue
                }
            }

            return trimmed.isEmpty ? (defaultValue ?? "") : trimmed
        }
    }

    private func promptForConfirmation(_ prompt: String, defaultYes: Bool = true) -> Bool {
        let options = defaultYes ? "[Y/n]" : "[y/N]"
        print("\(prompt) \(options): ", terminator: "")

        guard let input = readLine() else {
            return defaultYes
        }

        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return defaultYes
        }

        return trimmed == "y" || trimmed == "yes"
    }

    private func getCurrentDateISO8601() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: Date())
    }

    private func formatDateForDisplay(_ iso8601: String) -> String {
        // Extract just the date part for display
        if let date = ISO8601DateFormatter().date(from: iso8601) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        return iso8601
    }

    private func parseDateInput(_ input: String) -> String? {
        // If it's already ISO8601 format, return as-is
        if ISO8601DateFormatter().date(from: input) != nil {
            return input
        }

        // Try to parse YYYY-MM-DD format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = formatter.date(from: input) else {
            return nil
        }

        // Convert to ISO8601
        let iso8601Formatter = ISO8601DateFormatter()
        return iso8601Formatter.string(from: date)
    }

    private func launchEditor(filePath: String) {
        let editor = ProcessInfo.processInfo.environment["EDITOR"] ?? "vim"

        // Prepare arguments for exec (argv[0] is command name)
        let args = [editor, filePath]
        let argv: [UnsafeMutablePointer<CChar>?] = args.map { strdup($0) } + [nil]

        // Replace current process with editor
        execvp(editor, argv)

        // If we reach here, exec failed
        let errorMsg = String(cString: strerror(errno))
        print("Failed to launch editor '\(editor)': \(errorMsg)")
        print("You can manually edit the file at: \(filePath)")
    }
}
