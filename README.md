# 📘 Peadz PDF Reader

PeadZ es una aplicación de escritorio minimalista para macOS desarrollada en **SwiftUI**. Permite a los usuarios organizar, visualizar y leer archivos PDF de forma limpia, rápida y personalizable. Está diseñada para brindar una experiencia cómoda al leer documentos, con funcionalidades avanzadas como organización por carpetas, navegación fácil, modos de lectura y personalización visual.

---

## ✨ Características principales

- 📚 **Biblioteca visual** con miniaturas de PDFs organizados en carpetas personalizables.
- 📄 **Visor de PDFs** con funciones avanzadas:
  - Modo lectura sin distracciones, ocultando barras de control.
  - Modo sepia para reducir fatiga visual en ambientes oscuros.
  - Alternancia entre modo libro (vista doble página) o modo vertical continuo.
  - Navegación rápida por páginas, incluyendo ir a una página específica mediante input.
  - Agregar y eliminar marcadores para páginas importantes.
  - Zoom personalizable y persistente al cambiar de página.
- 🗂 Importación sencilla de PDFs y manejo flexible de carpetas para organización.
- 💾 Persistencia local automática de la biblioteca, carpetas y progreso de lectura por documento.
- 🧭 Atajos de teclado para alternar modos y navegación fluida.

---

## 🖥 Cómo funciona la aplicación

1. **Biblioteca de PDFs (`PDFLibraryView`)**  
   Al abrir la app, el usuario ve una grilla con miniaturas de todos los PDFs importados, organizados en carpetas. Puede filtrar para mostrar PDFs de una carpeta específica o todas. Cada miniatura incluye el nombre y una previsualización de la primera página.

2. **Importar y organizar**  
   El botón "+" abre un selector de archivos para importar nuevos PDFs. Al importar, se asignan a la carpeta actualmente seleccionada o a una carpeta "Sin Carpeta". El usuario puede crear nuevas carpetas para clasificar sus documentos y eliminar las que ya no use.

3. **Vista individual de PDF (`PDFViewer`)**  
   Al seleccionar un PDF, se abre el visor que muestra el documento con controles para navegar entre páginas, cambiar el modo de lectura, hacer zoom, alternar tema sepia, y marcar páginas importantes.

4. **Persistencia y estado**  
   La app guarda localmente los PDFs importados, sus carpetas, y la última página leída de cada documento. Esto permite que al reabrir la app o un documento, el usuario continúe exactamente donde lo dejó.

5. **Interactividad y accesibilidad**  
   Se incluyen animaciones suaves en las miniaturas y controles, así como menús contextuales para eliminar PDFs o carpetas. También cuenta con atajos de teclado (como `⌘ + L` para modo lectura) para mejorar la productividad.

---

## 🛠 Tecnologías usadas

- **SwiftUI** para la interfaz declarativa, dinámica y adaptable.
- **PDFKit** para la manipulación, visualización y navegación nativa de PDFs.
- **JSON + FileManager** para persistir la estructura de biblioteca y datos de usuario.
- **AppKit** para integración de vistas nativas de macOS donde SwiftUI no llega.
- **UniformTypeIdentifiers** para restringir la importación solo a archivos PDF.

---

## 🚀 Instalación y uso

1. Clona el repositorio:

   ```bash
   git clone https://github.com/Jorgito091/PeadZ.git
