import SwiftUI
import PDFKit

struct PDFViewer: View {
    let pdfDocument: PDFDocument
    @Binding var isPresented: Bool

    @State private var currentPageIndex: Int = 0
    @State private var isBookMode: Bool = true
    @State private var inputPage: String = "1"
    @State private var hovered = false

    var body: some View {
        VStack(spacing: 0) {
            // 🧭 Barra superior
            HStack(spacing: 16) {
                Text(pdfDocument.documentURL?.lastPathComponent ?? "Documento PDF")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Text("Página \(currentPageIndex + 1) de \(pdfDocument.pageCount)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                TextField("Ir a", text: $inputPage)
                    .frame(width: 50)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onReceive(inputPage.publisher.collect()) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            inputPage = String(filtered)
                        }
                    }
                    .onSubmit {
                        goToPage()
                    }

                Button(action: {
                    isBookMode.toggle()
                }) {
                    Image(systemName: isBookMode ? "rectangle.split.2x1" : "rectangle.portrait")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isBookMode ? .cyan : .white.opacity(0.85))
                        .padding(6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Cambiar modo de lectura")

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                        .opacity(hovered ? 1.0 : 0.8)
                        .scaleEffect(hovered ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: hovered)
                }
                .onHover { hovering in
                    hovered = hovering
                }
                .buttonStyle(PlainButtonStyle())
                .help("Cerrar visor")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .overlay(Divider().background(Color.white.opacity(0.15)), alignment: .bottom)

            // 📄 Visor PDF
            PDFKitEmbeddedView(
                pdfDocument: pdfDocument,
                currentPageIndex: $currentPageIndex,
                isBookMode: isBookMode
            )
            .frame(minWidth: 700, minHeight: 500)
        }
        .frame(minWidth: 700, minHeight: 550)
        .background(Color.black)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
        .onAppear {
            let key = pageStorageKey()
            let lastPage = UserDefaults.standard.integer(forKey: key)
            if lastPage >= 0 && lastPage < pdfDocument.pageCount {
                currentPageIndex = lastPage
                inputPage = "\(lastPage + 1)"
            } else {
                currentPageIndex = 0
                inputPage = "1"
            }
        }
        .onChange(of: currentPageIndex) { newValue in
            inputPage = "\(newValue + 1)"
            UserDefaults.standard.set(newValue, forKey: pageStorageKey())
        }
    }

    private func goToPage() {
        if let pageNum = Int(inputPage),
           pageNum > 0,
           pageNum <= pdfDocument.pageCount {
            currentPageIndex = pageNum - 1
        } else {
            inputPage = "\(currentPageIndex + 1)"
        }
    }

    private func pageStorageKey() -> String {
        return "PDFViewer_LastPage_" + (pdfDocument.documentURL?.lastPathComponent ?? "unknown")
    }
}

// MARK: - PDFKit Embedded View

struct PDFKitEmbeddedView: NSViewRepresentable {
    let pdfDocument: PDFDocument
    @Binding var currentPageIndex: Int
    var isBookMode: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        configureDisplay(for: pdfView)

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: Notification.Name.PDFViewPageChanged,
            object: pdfView
        )

        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = pdfDocument
        configureDisplay(for: pdfView)
        if let page = pdfDocument.page(at: currentPageIndex) {
            pdfView.go(to: page)
        }
    }

    private func configureDisplay(for pdfView: PDFView) {
        if isBookMode {
            pdfView.displayMode = .twoUp
            pdfView.displayDirection = .horizontal
            pdfView.displaysPageBreaks = true
        } else {
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
        }
        pdfView.autoScales = true
    }

    class Coordinator: NSObject {
        var parent: PDFKitEmbeddedView

        init(_ parent: PDFKitEmbeddedView) {
            self.parent = parent
        }

        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let page = pdfView.currentPage,
                  let index = pdfView.document?.index(for: page) else { return }

            DispatchQueue.main.async {
                self.parent.currentPageIndex = index
            }
        }
    }
}
