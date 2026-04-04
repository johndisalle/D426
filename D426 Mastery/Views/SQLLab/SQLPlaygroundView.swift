import SwiftUI
import SwiftData

struct SQLPlaygroundView: View {
    @StateObject private var sqlManager = SQLiteManager()
    @Query private var sampleDatabases: [SampleDatabase]

    @State private var queryText = "SELECT * FROM students;"
    @State private var result: SQLiteManager.QueryResult?
    @State private var selectedDB: SampleDatabase?
    @State private var showDBPicker = false
    @State private var showHistory = false
    @State private var showSchema = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Database selector
                dbSelector

                // Editor
                queryEditor

                // Run button
                runBar

                // Results
                resultArea
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SQL Playground")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showHistory = true } label: {
                            Label("History", systemImage: "clock.arrow.circlepath")
                        }
                        Button { showSchema = true } label: {
                            Label("Schema", systemImage: "tablecells")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showDBPicker) { dbPickerSheet }
            .sheet(isPresented: $showHistory) { historySheet }
            .sheet(isPresented: $showSchema) { schemaSheet }
        }
    }

    // MARK: - DB Selector
    private var dbSelector: some View {
        Button { showDBPicker = true } label: {
            HStack {
                Image(systemName: "cylinder.fill")
                    .foregroundStyle(.blue)
                Text(selectedDB?.name ?? "Select Database")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
        }
        .foregroundStyle(.primary)
    }

    // MARK: - Editor
    private var queryEditor: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Query Editor")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear") { queryText = "" }
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            TextEditor(text: $queryText)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120, maxHeight: 160)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - Run Bar
    private var runBar: some View {
        HStack(spacing: 12) {
            // Quick templates
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(["SELECT", "INSERT", "UPDATE", "DELETE", "JOIN"], id: \.self) { kw in
                        Button(kw) {
                            insertTemplate(kw)
                        }
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                    }
                }
            }

            Button {
                executeQuery()
            } label: {
                HStack(spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text("Run")
                        .font(.subheadline.bold())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.green)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .disabled(selectedDB == nil || queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - Results
    private var resultArea: some View {
        VStack(spacing: 0) {
            if let error = sqlManager.lastError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                    Spacer()
                }
                .padding()
                .background(.red.opacity(0.1))
            } else if let result {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(result.rows.count) rows")
                            .font(.caption.bold())
                        Spacer()
                        Text(String(format: "%.1fms", result.executionTime * 1000))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    if !result.columns.isEmpty {
                        ScrollView(.horizontal) {
                            resultTable(result)
                                .padding(.horizontal, 16)
                        }
                    } else {
                        Text("\(result.rowsAffected) rows affected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "terminal.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Results will appear here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func resultTable(_ result: SQLiteManager.QueryResult) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                ForEach(result.columns, id: \.self) { col in
                    Text(col)
                        .font(.caption.bold())
                        .frame(minWidth: 80, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
            }
            .background(Color(.tertiarySystemBackground))

            Divider()

            // Rows
            ForEach(Array(result.rows.prefix(100).enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                        Text(cell)
                            .font(.system(.caption, design: .monospaced))
                            .frame(minWidth: 80, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
                Divider()
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.vertical, 8)
    }

    // MARK: - Sheets
    private var dbPickerSheet: some View {
        NavigationStack {
            List(sampleDatabases) { db in
                Button {
                    selectedDB = db
                    _ = sqlManager.loadSampleDatabase(db)
                    showDBPicker = false
                } label: {
                    HStack {
                        Image(systemName: db.iconName)
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(db.name)
                                .font(.subheadline.weight(.medium))
                            Text(db.dbDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selectedDB?.id == db.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Sample Databases")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showDBPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var historySheet: some View {
        NavigationStack {
            List(sqlManager.queryHistory) { entry in
                Button {
                    queryText = entry.query
                    showHistory = false
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.query)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(2)
                        HStack {
                            Image(systemName: entry.success ? "checkmark.circle" : "xmark.circle")
                                .foregroundStyle(entry.success ? .green : .red)
                            Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption2)
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Query History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showHistory = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var schemaSheet: some View {
        NavigationStack {
            ScrollView {
                if let db = selectedDB {
                    SQLSyntaxText(sql: db.schemaSQL)
                        .padding()
                } else {
                    Text("Select a database first")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Schema")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showSchema = false }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Actions
    private func executeQuery() {
        guard selectedDB != nil else { return }
        isLoading = true
        DispatchQueue.global().async {
            let res = sqlManager.execute(sql: queryText)
            DispatchQueue.main.async {
                result = res
                isLoading = false
            }
        }
    }

    private func insertTemplate(_ keyword: String) {
        switch keyword {
        case "SELECT": queryText = "SELECT * FROM "
        case "INSERT": queryText = "INSERT INTO table_name (col1, col2) VALUES ('val1', 'val2');"
        case "UPDATE": queryText = "UPDATE table_name SET col1 = 'new_value' WHERE condition;"
        case "DELETE": queryText = "DELETE FROM table_name WHERE condition;"
        case "JOIN": queryText = "SELECT a.*, b.* FROM table1 a INNER JOIN table2 b ON a.id = b.foreign_id;"
        default: break
        }
    }
}
