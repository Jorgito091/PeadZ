import SwiftUI
import PDFKit

struct ThumbnailView: View {
    let url: URL

    var body: some View {
        if let doc = PDFDocument(url: url),
           let page = doc.page(at: 0) {
            Image(nsImage: page.thumbnail(of: CGSize(width: 120, height: 160), for: .cropBox))
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(Text("Sin vista previa").foregroundColor(.gray).font(.caption))
        }
    }
}
