import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFLibraryView: View {
    @StateObject var viewModel = PDFLibraryViewModel()
    @State private var showingOpenPanel = false
    @State private var selectedFolder: String = ""
    @State private var showingFolderPrompt = false
    @State private var newFolderName = ""
    @State private var showingDeleteFolderAlert = false
    @State private var folderToDelete: String? = nil

    let columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // 🧭 Top Bar
                HStack(spacing: 12) {
                    Menu {
                        Button("Todas las carpetas") {
                            selectedFolder = ""
                        }
                        ForEach(viewModel.folders, id: \.self) { folder in
                            Button(folder) {
                                selectedFolder = folder
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    folderToDelete = folder
                                    showingDeleteFolderAlert = true
                                } label: {
                                    Label("Eliminar carpeta", systemImage: "trash")
                                }
                            }
                        }
                        Button {
                            showingFolderPrompt = true
                        } label: {
                            Text("Nueva carpeta…")
                        }
                    } label: {
                        Text(selectedFolder.isEmpty ? "Todos" : selectedFolder)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.07))
                            )
                    }

                    Spacer()

                    Button(action: {
                        showingOpenPanel = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Agregar PDF")
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color.black)

                // 📚 Contenido
                if viewModel.pdfs.isEmpty {
                    Spacer()
                    Text("Tu biblioteca está vacía.")
                        .font(.callout.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredPDFs()) { item in
                                PDFGridItemView(item: item, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .fileImporter(isPresented: $showingOpenPanel, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    let folder = selectedFolder.isEmpty ? "Sin Carpeta" : selectedFolder
                    viewModel.addPDF(url: url, toFolder: folder)
                case .failure(let error):
                    print("Error importando PDF: \(error.localizedDescription)")
                }
            }
            .sheet(isPresented: $showingFolderPrompt) {
                VStack(spacing: 16) {
                    Text("Nueva carpeta")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Nombre", text: $newFolderName)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)
                        .foregroundColor(.white)

                    HStack {
                        Button("Cancelar") {
                            showingFolderPrompt = false
                            newFolderName = ""
                        }
                        Spacer()
                        Button("Crear") {
                            let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                selectedFolder = trimmed
                                showingFolderPrompt = false
                                newFolderName = ""
                            }
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.black)
                .cornerRadius(12)
                .frame(width: 320)
            }
            .alert("¿Eliminar la carpeta \"\(folderToDelete ?? "")\" y todos sus PDFs?", isPresented: $showingDeleteFolderAlert) {
                Button("Eliminar", role: .destructive) {
                    if let folder = folderToDelete {
                        viewModel.deleteFolder(folder)
                        if selectedFolder == folder {
                            selectedFolder = ""
                        }
                    }
                    folderToDelete = nil
                }
                Button("Cancelar", role: .cancel) {
                    folderToDelete = nil
                }
            }

            // 📄 Lado derecho: visor
            if let selectedPDF = viewModel.selectedPDF,
               let pdfDocument = PDFDocument(url: selectedPDF.fileURL) {
                PDFViewer(
                    pdfDocument: pdfDocument,
                    isPresented: Binding(
                        get: { viewModel.selectedPDF != nil },
                        set: { newValue in
                            if !newValue { viewModel.deselectPDF() }
                        })
                )
                .frame(minWidth: 700, minHeight: 600)
            } else {
                Text("Selecciona un PDF ")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.title3.weight(.medium))
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    func filteredPDFs() -> [PDFItem] {
        selectedFolder.isEmpty
            ? viewModel.pdfs
            : viewModel.pdfs.filter { $0.folder == selectedFolder }
    }
}
