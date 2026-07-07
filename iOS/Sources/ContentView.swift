import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: LogEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.accent)
                        Text("No entries yet")
                            .font(Theme.headlineFont)
                            .foregroundStyle(Theme.textPrimary)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button(action: { editingEntry = entry }) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(entry.tree)
                                            .font(Theme.headlineFont)
                                            .foregroundStyle(Theme.textPrimary)
                                        Spacer()
                                        Text(entry.date, style: .date)
                                            .font(Theme.captionFont)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    Text(entry.action)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.accent)
                                    if !entry.notes.isEmpty {
                                        Text(entry.notes)
                                            .font(Theme.captionFont)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                        .listRowBackground(Theme.cardBackground)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Growlog Bonsai")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(entry: nil)
                    .environmentObject(store)
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditorView(entry: entry)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(store)
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(purchases)
            }
        }
    }
}

struct EntryEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    let entry: LogEntry?
    @State private var tree: String
    @State private var action: String
    @State private var notes: String

    enum Field { case f0, f1, f2 }

    init(entry: LogEntry?) {
        self.entry = entry
        _tree = State(initialValue: entry?.tree ?? "")
        _action = State(initialValue: entry?.action ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tree") {
                    TextField("Tree", text: $tree)
                        .focused($focusedField, equals: .f0)
                        .accessibilityIdentifier("fieldTree")
                }
                Section("Action") {
                    TextField("Action", text: $action)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("fieldAction")
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("fieldNotes")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("editorCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = entry ?? LogEntry(tree: "", action: "", notes: "")
                        updated.tree = tree
                        updated.action = action
                        updated.notes = notes
                        if entry == nil {
                            store.add(updated)
                        } else {
                            store.update(updated)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("editorSaveButton")
                    .disabled(tree.isEmpty)
                }
            }
        }
    }
}
