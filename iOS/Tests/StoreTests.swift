import XCTest
@testable import Growlogbonsai

final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.entries = []
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(LogEntry(tree: "Test", action: "Value", notes: "Note"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testNewestEntryInsertedFirst() {
        store.add(LogEntry(tree: "First", action: "A", notes: ""))
        store.add(LogEntry(tree: "Second", action: "B", notes: ""))
        XCTAssertEqual(store.entries.first?.tree, "Second")
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreWhenAtFreeLimit() {
        for i in 0..<Store.freeTierLimit {
            store.add(LogEntry(tree: "Item \(i)", action: "V", notes: ""))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testAddBeyondLimitIsNoOp() {
        for i in 0..<Store.freeTierLimit {
            store.add(LogEntry(tree: "Item \(i)", action: "V", notes: ""))
        }
        let countAtLimit = store.entries.count
        store.add(LogEntry(tree: "Overflow", action: "V", notes: ""))
        XCTAssertEqual(store.entries.count, countAtLimit)
    }

    func testDeleteAtOffsetsRemovesEntry() {
        store.add(LogEntry(tree: "ToDelete", action: "V", notes: ""))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertTrue(store.entries.isEmpty)
    }

    func testUpdateEntryModifiesExisting() {
        store.add(LogEntry(tree: "Original", action: "V", notes: ""))
        var entry = store.entries[0]
        entry.tree = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries[0].tree, "Updated")
    }

    func testFreeTierLimitExceedsSeedCount() {
        XCTAssertGreaterThan(Store.freeTierLimit, 3)
    }
}
