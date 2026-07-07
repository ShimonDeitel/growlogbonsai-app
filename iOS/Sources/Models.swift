import Foundation

struct LogEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var tree: String
    var action: String
    var notes: String
    var date: Date = Date()
}
