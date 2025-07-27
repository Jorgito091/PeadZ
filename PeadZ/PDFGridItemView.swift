import SwiftUI

struct PDFGridItemView: View {
    let item: PDFItem
    let viewModel: PDFLibraryViewModel
    @State private var isHovered = false
    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(spacing: 10) {
            ThumbnailView(url: item.fileURL)
                .frame(width: 140, height: 190)
                .cornerRadius(12)
                .shadow(color: .orange.opacity(0.4), radius: isHovered ? 8 : 4, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHovered ? Color.orange : Color.clear, lineWidth: 1.5)
                )

            Text(item.fileName)
                .font(.caption.weight(.medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: 140)
                .padding(.horizontal, 4)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .background(Color.black.opacity(0.5))
                .shadow(color: .orange.opacity(0.2), radius: isHovered ? 6 : 3, x: 0, y: 2)
        )
        .onTapGesture {
            viewModel.selectedPDF = item
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Eliminar PDF", systemImage: "trash")
            }
        }
        .alert("¿Eliminar este PDF?", isPresented: $showingDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                viewModel.deletePDF(item)
            }
            Button("Cancelar", role: .cancel) {}
        }
    }
}
