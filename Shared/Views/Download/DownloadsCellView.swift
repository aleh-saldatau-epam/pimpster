//
//  DownloadsCellView.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 22.02.21.
//

import SwiftUI

struct DownloadsCellView: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    @StateObject var dItem: DownloadItem
    var body: some View {
        VStack {
            Text(dItem.iTunesTitle ?? "No Title")
            Text(dItem.iTunesSubtitle ?? "No SubTitle")
            switch dItem.state {
            case .initial:
                Text("Waiting for download to start")
            case .downloading:
                if let downloadProgress = dItem.downloadProgress {
                    ProgressView(downloadProgress)
                }
            case .downloaded:
                Button("Play") {
                    print("Play \(String(describing: dItem.urlToPlayFrom?.absoluteURL))")
                    playerBrain.playableItem = dItem
                }
            }
        }
    }
}

struct DownloadsCellView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsCellView(dItem: DownloadItem())
    }
}
