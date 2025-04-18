import XCTest
@testable import BBGCore

final class DocumentMetadataTests: XCTestCase {

    func testParseValidMetadata() throws {
        // Given
        let validYaml = """
        date: "2023-01-01T12:00:00Z"
        title: Test Title
        slug: test-slug
        """

        // When
        let metadata = try DocumentMetadata.parse(data: validYaml)

        // Then
        XCTAssertEqual(metadata.title, "Test Title")
        XCTAssertEqual(metadata.slug, "test-slug")

        let formatter = ISO8601DateFormatter()
        let expectedDate = formatter.date(from: "2023-01-01T12:00:00Z")
        XCTAssertEqual(metadata.date, expectedDate)
    }

    func testParseWithMissingTitle() throws {
        // Given
        let yamlWithoutTitle = """
        date: "2023-01-01T12:00:00Z"
        slug: test-slug
        """

        // When
        let metadata = try DocumentMetadata.parse(data: yamlWithoutTitle)

        // Then
        XCTAssertNil(metadata.title)
        XCTAssertEqual(metadata.slug, "test-slug")
    }

    func testParseWithMissingSlug() throws {
        // Given
        let yamlWithoutSlug = """
        date: "2023-01-01T12:00:00Z"
        title: Test Title
        """

        // When
        let metadata = try DocumentMetadata.parse(data: yamlWithoutSlug)

        // Then
        XCTAssertEqual(metadata.title, "Test Title")
        XCTAssertNil(metadata.slug)
    }

    func testParseWithMissingDate() {
        // Given
        let yamlWithoutDate = """
        title: Test Title
        slug: test-slug
        """

        // When/Then
        XCTAssertThrowsError(try DocumentMetadata.parse(data: yamlWithoutDate)) { error in
            XCTAssertEqual(error as? MetadataError, MetadataError.missingDate)
        }
    }

    func testParseWithInvalidDate() {
        // Given
        let yamlWithInvalidDate = """
        date: not-a-date
        title: Test Title
        slug: test-slug
        """

        // When/Then
        XCTAssertThrowsError(try DocumentMetadata.parse(data: yamlWithInvalidDate)) { error in
            XCTAssertEqual(error as? MetadataError, MetadataError.invalidDate)
        }
    }

    func testParseWithEmptyData() throws {
        // When/Then
        XCTAssertThrowsError(try DocumentMetadata.parse(data: nil)) { error in
            XCTAssertEqual(error as? MetadataError, MetadataError.missingDate)
        }
    }
}
