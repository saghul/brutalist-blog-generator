import XCTest
import Markdown
@testable import BBGCore

final class DocumentTests: XCTestCase {

    // Temporary directory path to store all test files
    private var tempDirectoryPath: String!

    override func setUp() {
        super.setUp()

        // Create a unique temporary directory for this test run
        tempDirectoryPath = NSTemporaryDirectory().appending("/DocumentTests_\(UUID().uuidString)")

        // Create the directory
        try! FileManager.default.createDirectory(
            atPath: tempDirectoryPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    // Clean up after all tests
    override func tearDown() {
        super.tearDown()

        // Remove the temporary directory and all its contents
        if tempDirectoryPath != nil {
            try? FileManager.default.removeItem(atPath: tempDirectoryPath)
        }
    }

    // Helper to create temporary files for testing
    func createTempFile(content: String) -> String {
        let tempFileName = UUID().uuidString
        let tempPath = (tempDirectoryPath as NSString).appendingPathComponent(tempFileName)

        try! content.write(toFile: tempPath, atomically: true, encoding: .utf8)
        return tempPath
    }

    func testParseValidDocument() throws {
        // Given
        let content = """
        ---
        date: "2023-01-15T12:00:00Z"
        title: "Test Document"
        slug: "test-doc"
        ---

        # Test Document

        This is a test document.
        """

        let tempPath = createTempFile(content: content)

        // When
        let document = try Document.parse(path: tempPath)

        // Then
        XCTAssertEqual(document.title, "Test Document")
        XCTAssertEqual(document.slug, "test-doc")
        XCTAssertEqual(document.fileName, "2023-01-test-doc.html")

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: document.date), 2023)
        XCTAssertEqual(calendar.component(.month, from: document.date), 1)
        XCTAssertEqual(calendar.component(.day, from: document.date), 15)
    }

    func testParseDocumentWithoutTitle() {
        // Given
        let content = """
        ---
        date: "2023-01-15T12:00:00Z"
        ---

        This is a test document with no title.
        """

        let tempPath = createTempFile(content: content)

        // When/Then
        XCTAssertThrowsError(try Document.parse(path: tempPath)) { error in
            XCTAssertEqual(error as? DocumentError, DocumentError.missingTitle)
        }
    }

    func testParseDocumentWithTitleInContent() throws {
        // Given
        let content = """
        ---
        date: "2023-01-15T12:00:00Z"
        ---

        # Content Title

        This is a test document with title in the content.
        """

        let tempPath = createTempFile(content: content)

        // When
        let document = try Document.parse(path: tempPath)

        // Then
        XCTAssertEqual(document.title, "Content Title")
        XCTAssertEqual(document.slug, "content-title")
    }

    func testParseDocumentWithInvalidSlug() {
        // Given
        let content = """
        ---
        date: "2023-01-15T12:00:00Z"
        title: "!@#$%^&*()"
        ---

        This is a test document with invalid slug characters.
        """

        let tempPath = createTempFile(content: content)

        // When/Then
        XCTAssertThrowsError(try Document.parse(path: tempPath)) { error in
            XCTAssertEqual(error as? DocumentError, DocumentError.invalidSlug)
        }
    }

    func testParseDocumentWithSlugOverride() throws {
        // Given
        let content = """
        ---
        date: "2023-01-15T12:00:00Z"
        title: "Original Title"
        slug: "custom-slug"
        ---

        # Different Title in Content

        This tests that the slug override works.
        """

        let tempPath = createTempFile(content: content)

        // When
        let document = try Document.parse(path: tempPath)

        // Then
        XCTAssertEqual(document.title, "Original Title")
        XCTAssertEqual(document.slug, "custom-slug")
    }

    func testParseDocumentWithoutFrontMatter() {
        // Given
        let content = """
        # Document Title

        This is a document without front matter.
        """

        let tempPath = createTempFile(content: content)

        // When/Then
        XCTAssertThrowsError(try Document.parse(path: tempPath)) { error in
            XCTAssertEqual(error as? MetadataError, MetadataError.missingDate)
        }
    }

    func testDocumentFileName() throws {
        // Given
        let content = """
        ---
        date: "2023-07-15T12:00:00Z"
        title: "Test Document"
        ---

        # Test Document
        """

        let tempPath = createTempFile(content: content)

        // When
        let document = try Document.parse(path: tempPath)

        // Then
        XCTAssertEqual(document.fileName, "2023-07-test-document.html")
    }

    func testToHtml() throws {
        // Given
        let content = """
        ---
        date: "2023-01-15T12:00:00Z"
        title: "Markdown Test"
        ---

        This is **bold** and *italic* text.
        """

        let tempPath = createTempFile(content: content)

        // When
        let document = try Document.parse(path: tempPath)
        let html = document.toHtml()

        // Then
        XCTAssertTrue(html.contains("<strong>bold</strong>"))
        XCTAssertTrue(html.contains("<em>italic</em>"))
    }

    func testSlugify() {
        // Test basic slugification
        XCTAssertEqual(Document.slugify("Hello World"), "hello-world")

        // Test special characters
        XCTAssertEqual(Document.slugify("Hello, World!"), "hello-world")

        // Test accented characters
        XCTAssertEqual(Document.slugify("Café au lait"), "cafe-au-lait")

        // Test multiple spaces and dashes
        XCTAssertEqual(Document.slugify("Hello  -  World"), "hello-world")

        // Test empty string
        XCTAssertNil(Document.slugify(""))

        // Test string with only special characters
        XCTAssertNil(Document.slugify("!@#$%^&*()"))
    }

    func testSplitFrontMatter() {
        // Test valid front matter
        let validContent = """
        ---
        key: value
        another: thing
        ---
        Content here
        More content
        """

        let validParts = Document.splitFrontMatter(from: validContent)
        XCTAssertEqual(validParts.yaml, "key: value\nanother: thing")
        XCTAssertEqual(validParts.content, "Content here\nMore content")

        // Test without front matter
        let noFrontMatter = "Just content\nNo front matter here"
        let emptyParts = Document.splitFrontMatter(from: noFrontMatter)
        XCTAssertEqual(emptyParts.yaml, "")
        XCTAssertEqual(emptyParts.content, noFrontMatter)
    }
}
