import Foundation
import SQLite3

/// Lightweight SQLite wrapper for the SQL Playground
final class SQLiteManager: ObservableObject {
    private var db: OpaquePointer?
    @Published var lastError: String?
    @Published var queryHistory: [QueryHistoryEntry] = []

    struct QueryResult {
        var columns: [String]
        var rows: [[String]]
        var rowsAffected: Int
        var executionTime: TimeInterval
    }

    struct QueryHistoryEntry: Identifiable {
        let id = UUID()
        let query: String
        let timestamp: Date
        let success: Bool
    }

    init() {}

    func openDatabase(named name: String) -> Bool {
        close()
        let path = Self.dbPath(for: name)
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
        if sqlite3_open_v2(path, &db, flags, nil) != SQLITE_OK {
            lastError = String(cString: sqlite3_errmsg(db))
            return false
        }
        return true
    }

    func execute(sql: String) -> QueryResult? {
        guard let db = db else {
            lastError = "No database open"
            return nil
        }

        let start = CFAbsoluteTimeGetCurrent()
        let statements = sql.split(separator: ";", omittingEmptySubsequences: true)
        var finalResult: QueryResult?

        for statement in statements {
            let trimmed = statement.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, trimmed, -1, &stmt, nil) != SQLITE_OK {
                let err = String(cString: sqlite3_errmsg(db))
                lastError = err
                addHistory(query: trimmed, success: false)
                return nil
            }

            let colCount = sqlite3_column_count(stmt)
            var columns: [String] = []
            for i in 0..<colCount {
                let name = sqlite3_column_name(stmt, i).map { String(cString: $0) } ?? "col\(i)"
                columns.append(name)
            }

            var rows: [[String]] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                var row: [String] = []
                for i in 0..<colCount {
                    if let text = sqlite3_column_text(stmt, i) {
                        row.append(String(cString: text))
                    } else {
                        row.append("NULL")
                    }
                }
                rows.append(row)
            }

            let affected = Int(sqlite3_changes(db))
            sqlite3_finalize(stmt)

            finalResult = QueryResult(
                columns: columns,
                rows: rows,
                rowsAffected: affected,
                executionTime: CFAbsoluteTimeGetCurrent() - start
            )
        }

        lastError = nil
        addHistory(query: sql.trimmingCharacters(in: .whitespacesAndNewlines), success: true)
        return finalResult
    }

    func loadSampleDatabase(_ sample: SampleDatabase) -> Bool {
        guard openDatabase(named: sample.name) else { return false }
        _ = execute(sql: sample.schemaSQL)
        if lastError != nil { return false }
        _ = execute(sql: sample.sampleDataSQL)
        return lastError == nil
    }

    func close() {
        if let db = db {
            sqlite3_close(db)
        }
        db = nil
    }

    private func addHistory(query: String, success: Bool) {
        let entry = QueryHistoryEntry(query: query, timestamp: .now, success: success)
        queryHistory.insert(entry, at: 0)
        if queryHistory.count > 100 { queryHistory.removeLast() }
    }

    private static func dbPath(for name: String) -> String {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("\(name).sqlite").path
    }

    deinit { close() }
}
