import SwiftUI

struct ExercisePickerPage: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore
    let onSelect: (ExerciseLibraryItem) -> Void
    @State private var searchText = ""
    @State private var isAddingCustomExercise = false
    @State private var editingCustomExercise: ExerciseLibraryItem?

    private var filteredItems: [ExerciseLibraryItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let allItems = customExerciseStore.items + ExerciseLibrary.items
        guard !query.isEmpty else { return allItems }

        return allItems.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.category.localizedCaseInsensitiveContains(query) ||
            $0.primaryMuscle.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredItems) { item in
                Button {
                    onSelect(item)
                    dismiss()
                } label: {
                    exerciseRow(for: item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if isCustom(item) {
                        Button(role: .destructive) {
                            customExerciseStore.delete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            editingCustomExercise = item
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercise List")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isAddingCustomExercise = true
                    } label: {
                        Label("Add Custom Exercise", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingCustomExercise) {
                CustomExerciseEditorPage { item in
                    customExerciseStore.add(item)
                    onSelect(item)
                    dismiss()
                }
            }
            .sheet(item: $editingCustomExercise) { item in
                CustomExerciseEditorPage(item: item) { updatedItem in
                    customExerciseStore.update(updatedItem)
                }
            }
        }
    }

    private func exerciseRow(for item: ExerciseLibraryItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text("\(item.category) • \(item.primaryMuscle) • \(item.trackingType.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isCustom(item) {
                Text("Custom")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.12), in: Capsule())
                    .foregroundStyle(.blue)
            }
        }
    }

    private func isCustom(_ item: ExerciseLibraryItem) -> Bool {
        customExerciseStore.items.contains { $0.id == item.id }
    }
}

private struct CustomExerciseEditorPage: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (ExerciseLibraryItem) -> Void
    private let itemID: UUID
    private let saveTitle: String
    private let navigationTitle: String
    @State private var name = ""
    @State private var category = "Custom"
    @State private var primaryMuscle = ""
    @State private var trackingType: ExerciseTrackingType = .reps

    init(item: ExerciseLibraryItem? = nil, onSave: @escaping (ExerciseLibraryItem) -> Void) {
        self.onSave = onSave
        itemID = item?.id ?? UUID()
        saveTitle = item == nil ? "Add" : "Save"
        navigationTitle = item == nil ? "Custom Exercise" : "Edit Exercise"
        _name = State(initialValue: item?.name ?? "")
        _category = State(initialValue: item?.category ?? "Custom")
        _primaryMuscle = State(initialValue: item?.primaryMuscle ?? "")
        _trackingType = State(initialValue: item?.trackingType ?? .reps)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name", text: $name)
                    TextField("Category", text: $category)
                    TextField("Primary muscle", text: $primaryMuscle)
                    Picker("Track by", selection: $trackingType) {
                        ForEach(ExerciseTrackingType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(saveTitle) {
                        onSave(
                            ExerciseLibraryItem(
                                id: itemID,
                                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Custom" : category,
                                primaryMuscle: primaryMuscle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Custom" : primaryMuscle,
                                trackingType: trackingType
                            )
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
