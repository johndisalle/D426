import SwiftUI

// MARK: - ER Models
struct EREntity: Identifiable {
    let id = UUID()
    var name: String
    var attributes: [ERAttribute]
    var position: CGPoint
    var color: Color
}

struct ERAttribute: Identifiable {
    let id = UUID()
    var name: String
    var isPrimaryKey: Bool
    var isForeignKey: Bool
    var dataType: String
}

struct ERRelationship: Identifiable {
    let id = UUID()
    var fromEntityId: UUID
    var toEntityId: UUID
    var label: String
    var fromCardinality: Cardinality
    var toCardinality: Cardinality
}

enum Cardinality: String, CaseIterable {
    case one = "1"
    case many = "M"
    case zeroOrOne = "0..1"
    case zeroOrMany = "0..M"
    case oneOrMany = "1..M"

    var displayName: String { rawValue }
}

// MARK: - ER Builder View
struct ERBuilderView: View {
    @State private var entities: [EREntity] = []
    @State private var relationships: [ERRelationship] = []
    @State private var selectedEntityId: UUID?
    @State private var showAddEntity = false
    @State private var showAddRelationship = false
    @State private var showPremiumGate = false
    @State private var draggedEntityId: UUID?
    @State private var dragOffset: CGSize = .zero

    var isPremium: Bool { PremiumManager.shared.isPremium }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if !isPremium {
                    premiumGateView
                } else {
                    canvasView
                }
            }
            .navigationTitle("ER Diagram Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isPremium {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button { showAddRelationship = true } label: {
                            Image(systemName: "line.diagonal")
                        }
                        .disabled(entities.count < 2)

                        Button { showAddEntity = true } label: {
                            Image(systemName: "plus.rectangle.fill")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Clear") {
                            entities.removeAll()
                            relationships.removeAll()
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEntity) { addEntitySheet }
            .sheet(isPresented: $showAddRelationship) { addRelationshipSheet }
        }
    }

    // MARK: - Canvas
    private var canvasView: some View {
        ZStack {
            // Grid background
            GridPattern()
                .stroke(.gray.opacity(0.1), lineWidth: 0.5)
                .ignoresSafeArea()

            // Relationships
            ForEach(relationships) { rel in
                if let from = entities.first(where: { $0.id == rel.fromEntityId }),
                   let to = entities.first(where: { $0.id == rel.toEntityId }) {
                    RelationshipLine(
                        from: from.position,
                        to: to.position,
                        fromCard: rel.fromCardinality,
                        toCard: rel.toCardinality,
                        label: rel.label
                    )
                }
            }

            // Entities
            ForEach(entities) { entity in
                EntityView(entity: entity, isSelected: selectedEntityId == entity.id)
                    .position(entity.position)
                    .onTapGesture { selectedEntityId = entity.id }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if let idx = entities.firstIndex(where: { $0.id == entity.id }) {
                                    entities[idx].position = value.location
                                }
                            }
                    )
            }

            if entities.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.3.group")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Tap + to add entities")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Premium Gate
    private var premiumGateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("Premium Feature")
                .font(.title2.bold())
            Text("The interactive ER Diagram Builder\nis available with D426 Mastery Premium.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            NavigationLink("Unlock Premium") {
                PremiumView()
            }
            .font(.headline)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
        }
    }

    // MARK: - Add Entity
    private var addEntitySheet: some View {
        AddEntitySheet { entity in
            entities.append(entity)
            showAddEntity = false
        }
    }

    // MARK: - Add Relationship
    private var addRelationshipSheet: some View {
        AddRelationshipSheet(entities: entities) { rel in
            relationships.append(rel)
            showAddRelationship = false
        }
    }
}

// MARK: - Entity View
struct EntityView: View {
    let entity: EREntity
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(entity.name)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(entity.color)

            // Attributes
            VStack(alignment: .leading, spacing: 2) {
                ForEach(entity.attributes) { attr in
                    HStack(spacing: 4) {
                        if attr.isPrimaryKey {
                            Image(systemName: "key.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(.yellow)
                        }
                        if attr.isForeignKey {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(.blue)
                        }
                        Text(attr.name)
                            .font(.system(size: 10, design: .monospaced))
                        Spacer()
                        Text(attr.dataType)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 6)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(width: 140)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? .blue : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

// MARK: - Relationship Line
struct RelationshipLine: View {
    let from: CGPoint
    let to: CGPoint
    let fromCard: Cardinality
    let toCard: Cardinality
    let label: String

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(.gray, lineWidth: 1.5)

            // Cardinality labels
            Text(fromCard.displayName)
                .font(.system(size: 9, weight: .bold))
                .position(
                    x: from.x + (to.x - from.x) * 0.15,
                    y: from.y + (to.y - from.y) * 0.15 - 10
                )

            Text(toCard.displayName)
                .font(.system(size: 9, weight: .bold))
                .position(
                    x: from.x + (to.x - from.x) * 0.85,
                    y: from.y + (to.y - from.y) * 0.85 - 10
                )

            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
                .position(
                    x: (from.x + to.x) / 2,
                    y: (from.y + to.y) / 2 - 12
                )
        }
    }
}

// MARK: - Grid Pattern
struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 20
        for x in stride(from: 0, to: rect.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, to: rect.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

// MARK: - Add Entity Sheet
struct AddEntitySheet: View {
    let onAdd: (EREntity) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var attributes: [ERAttribute] = [
        ERAttribute(name: "id", isPrimaryKey: true, isForeignKey: false, dataType: "INT")
    ]
    @State private var newAttrName = ""
    @State private var newAttrType = "INT"
    @State private var newAttrIsPK = false
    @State private var newAttrIsFK = false

    private let dataTypes = ["INT", "VARCHAR", "TEXT", "DATE", "DECIMAL", "BOOLEAN", "FLOAT"]
    private let colors: [Color] = [.blue, .green, .purple, .orange, .red, .teal, .pink]

    var body: some View {
        NavigationStack {
            Form {
                Section("Entity Name") {
                    TextField("e.g. Student", text: $name)
                }
                Section("Attributes") {
                    ForEach(attributes) { attr in
                        HStack {
                            if attr.isPrimaryKey { Image(systemName: "key.fill").foregroundStyle(.yellow).font(.caption) }
                            if attr.isForeignKey { Image(systemName: "arrow.right.circle.fill").foregroundStyle(.blue).font(.caption) }
                            Text(attr.name)
                            Spacer()
                            Text(attr.dataType).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indices in attributes.remove(atOffsets: indices) }
                }
                Section("Add Attribute") {
                    TextField("Name", text: $newAttrName)
                    Picker("Type", selection: $newAttrType) {
                        ForEach(dataTypes, id: \.self) { Text($0) }
                    }
                    Toggle("Primary Key", isOn: $newAttrIsPK)
                    Toggle("Foreign Key", isOn: $newAttrIsFK)
                    Button("Add Attribute") {
                        guard !newAttrName.isEmpty else { return }
                        attributes.append(ERAttribute(name: newAttrName, isPrimaryKey: newAttrIsPK, isForeignKey: newAttrIsFK, dataType: newAttrType))
                        newAttrName = ""
                        newAttrIsPK = false
                        newAttrIsFK = false
                    }
                }
            }
            .navigationTitle("New Entity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let entity = EREntity(
                            name: name,
                            attributes: attributes,
                            position: CGPoint(x: CGFloat.random(in: 100...300), y: CGFloat.random(in: 100...400)),
                            color: colors.randomElement() ?? .blue
                        )
                        onAdd(entity)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Relationship Sheet
struct AddRelationshipSheet: View {
    let entities: [EREntity]
    let onAdd: (ERRelationship) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var fromId: UUID?
    @State private var toId: UUID?
    @State private var label = ""
    @State private var fromCard: Cardinality = .one
    @State private var toCard: Cardinality = .many

    var body: some View {
        NavigationStack {
            Form {
                Section("From Entity") {
                    Picker("Entity", selection: $fromId) {
                        Text("Select...").tag(nil as UUID?)
                        ForEach(entities) { e in Text(e.name).tag(e.id as UUID?) }
                    }
                    Picker("Cardinality", selection: $fromCard) {
                        ForEach(Cardinality.allCases, id: \.self) { c in Text(c.displayName).tag(c) }
                    }
                }
                Section("To Entity") {
                    Picker("Entity", selection: $toId) {
                        Text("Select...").tag(nil as UUID?)
                        ForEach(entities) { e in Text(e.name).tag(e.id as UUID?) }
                    }
                    Picker("Cardinality", selection: $toCard) {
                        ForEach(Cardinality.allCases, id: \.self) { c in Text(c.displayName).tag(c) }
                    }
                }
                Section("Label") {
                    TextField("e.g. enrolls in", text: $label)
                }
            }
            .navigationTitle("New Relationship")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let from = fromId, let to = toId else { return }
                        let rel = ERRelationship(fromEntityId: from, toEntityId: to, label: label, fromCardinality: fromCard, toCardinality: toCard)
                        onAdd(rel)
                    }
                    .disabled(fromId == nil || toId == nil || fromId == toId)
                }
            }
        }
    }
}
