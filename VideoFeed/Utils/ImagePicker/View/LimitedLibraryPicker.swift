//
//  LimitedLibraryPicker.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/28/24.
//

import SwiftUI
import PhotosUI

struct LimitedLibraryPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ImagePickerViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: uiViewController) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                    
                }
                
            }
        }
    }
}
