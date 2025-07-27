import Foundation

struct PDFItem: Identifiable, Codable, Equatable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let folder: String?

    init(id: UUID = UUID(), fileName: String, fileURL: URL, folder: String?) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.folder = folder
    }

    static func == (lhs: PDFItem, rhs: PDFItem) -> Bool {
        lhs.fileURL == rhs.fileURL
    }
}
