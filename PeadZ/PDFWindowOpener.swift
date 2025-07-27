import SwiftUI
import PDFKit
import AppKit

struct PDFWindowOpener {
    static func open(pdf: PDFDocument, title: String) {
        let pdfView = PDFView()
        pdfView.document = pdf
        pdfView.autoScales = true

        let hostingView = NSHostingView(rootView: PDFKitWrapper(pdfView: pdfView))

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
    }
}

struct PDFKitWrapper: NSViewRepresentable {
    let pdfView: PDFView

    func makeNSView(context: Context) -> NSView {
        return pdfView
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
