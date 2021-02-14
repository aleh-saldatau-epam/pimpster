//
//  ImageFromURLView.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 13.02.21.
//

import SwiftUI

struct ImageFromURLView: View {
    @StateObject var imageLoader: ImageLoader

    var body: some View {
        Group {
            switch imageLoader.state {
            case .idle:
                Color.clear
                    .frame(width: 20, height: 20)
                    .onAppear(perform: imageLoader.loadImage)
            case .loading:
                ProgressView()
                    .frame(width: 20, height: 20)
            case .failed(_):
                Image(systemName: "questionmark.square")
                    .resizable()
                    .frame(width: 20, height: 20)
            case .loaded:
                ImageOSDependentView(imageData: imageLoader.imageData)
            }
        }
    }
}

struct ImageOSDependentView: View {
    let imageData: Data?
    var body: some View {
        #if os(OSX)
        Image(nsImage: NSImage(data: imageData!)!)
            .resizable()
            .frame(width: 20, height: 20)
        #else
        Image(uiImage: UIImage(data: imageData!)!)
            .resizable()
            .frame(width: 20, height: 20)
        #endif

    }
}

