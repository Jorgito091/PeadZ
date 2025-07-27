import Foundation

class PDFLibraryViewModel: ObservableObject {
    @Published var pdfs: [PDFItem] = []
    @Published var folders: [String] = []
    @Published var selectedPDF: PDFItem?

    private let saveFileName = "bibliotecaPDFs.json"

    init() {
        loadPDFs()
    }

    func addPDF(url: URL, toFolder folder: String) {
        let newPDF = PDFItem(fileName: url.lastPathComponent, fileURL: url, folder: folder)
        if !pdfs.contains(newPDF) {
            pdfs.append(newPDF)
            if !folders.contains(folder) {
                folders.append(folder)
            }
            savePDFs()
        }
    }

    func deleteFolder(_ folder: String) {
        pdfs.removeAll { $0.folder == folder }
        folders.removeAll { $0 == folder }
        savePDFs()
    }

    func deselectPDF() {
        selectedPDF = nil
    }
    func deletePDF(_ pdf: PDFItem) {
        // Eliminar el PDF de la lista
        pdfs.removeAll { $0.id == pdf.id }
        
        // Actualizar carpetas por si alguna quedó vacía
        folders = Array(Set(pdfs.compactMap { $0.folder })).sorted()
        
        // Guardar cambios en disco
        savePDFs()
    }   
    private func savePDFs() {
        do {
            let data = try JSONEncoder().encode(pdfs)
            let url = getDocumentsDirectory().appendingPathComponent(saveFileName)
            try data.write(to: url)
        } catch {
            print("Error guardando PDFs: \(error.localizedDescription)")
        }
    }

    private func loadPDFs() {
        let url = getDocumentsDirectory().appendingPathComponent(saveFileName)
        guard let data = try? Data(contentsOf: url) else { return }

        do {
            let loadedPDFs = try JSONDecoder().decode([PDFItem].self, from: data)
            self.pdfs = loadedPDFs
            self.folders = Array(Set(loadedPDFs.compactMap { $0.folder })).sorted()
        } catch {
            print("Error cargando PDFs: \(error.localizedDescription)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
