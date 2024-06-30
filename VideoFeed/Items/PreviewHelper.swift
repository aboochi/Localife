import Foundation
import SwiftUI

struct PreviewHelper<Content: View, Preview: View>: UIViewRepresentable {
    var content: Content
    var preview: Preview
    var actions: UIMenu

    init(content: Content, preview: Preview, actions: UIMenu) {
        self.content = content
        self.preview = preview
        self.actions = actions
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hostView.view)

        NSLayoutConstraint.activate([
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])

        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: PreviewHelper

        init(parent: PreviewHelper) {
            self.parent = parent
        }

        func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                    configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            let previewController = UIHostingController(rootView: self.parent.preview)
            previewController.view.backgroundColor = .clear
            
            
            print("Ipad screen inside helper: \(UIScreen.main.bounds)")

            // Calculate a dynamic frame size for the preview
            let screenBounds = UIScreen.main.bounds
            let width = screenBounds.width * 0.90 // 80% of screen width
            let height = screenBounds.height * 0.6 // 40% of screen height
            previewController.preferredContentSize = CGSize(width: width, height: height)

            return UIContextMenuConfiguration(identifier: nil) {
                return previewController
            } actionProvider: { _ in
                return self.parent.actions
            }
        }
    }
}
