import SwiftUI

struct ChatHistoryPage: View {
    @EnvironmentObject private var chatStore: CoachChatStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if chatStore.sessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Belum ada chat")
                            .font(.headline)
                        Text("Mulai chat baru dengan coach.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(chatStore.sessions) { session in
                        Button {
                            chatStore.switchTo(session.id)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(session.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Text(session.updatedAt, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if session.id == chatStore.activeSessionID {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { i in
                            chatStore.deleteSession(chatStore.sessions[i].id)
                        }
                    }
                }
            }
            .navigationTitle("Riwayat Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Tutup") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        chatStore.newSession()
                        dismiss()
                    } label: {
                        Label("New Chat", systemImage: "square.and.pencil")
                    }
                }
            }
        }
    }
}
