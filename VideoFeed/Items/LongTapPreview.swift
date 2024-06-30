//
//  LongTapPreview.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/20/24.
//

import SwiftUI
import Combine


struct LongTapPreview<Content: View, Preview: View>: View {
    var content: () -> Content
    var menu: UIMenu
    @Binding var updatePreviewUI: Bool
    
    @State private var previewID = UUID()
    private var previewClosure: () -> Preview // Store the closure for recreation
    
    init(updatePreviewUI: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder preview: @escaping () -> Preview,
         @ViewBuilder actions: @escaping () -> UIMenu
         // Accept preview as a closure
    ) {
        self.content = content
        self.menu = actions()
        self._updatePreviewUI = updatePreviewUI
        self.previewClosure = preview // Store the closure
    }
    
    var body: some View {
        ZStack {
            content()
                .hidden()
                .overlay {
                    PreviewHelper(content: content(), preview: previewClosure(), actions: menu)
                }
        }
        .id(previewID)
        .onChange(of: updatePreviewUI) { _ in
            previewID = UUID()
        }
    }
}


