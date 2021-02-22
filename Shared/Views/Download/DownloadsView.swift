//
//  DownloadsView.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 22.02.21.
//

import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject var downloadsBrain: DownloadsBrain
    var body: some View {
        NavigationView {
            Group {
                switch downloadsBrain.state {
                case .idle:
                    Color.clear.onAppear(perform: downloadsBrain.scanDownloads)
                case .scanningDownloads:
                    ProgressView()
                case .emptyDownloads:
                    Text("No downloads")
                case .showDownloads:
                    List {
                        ForEach(downloadsBrain.downloadItems, id: \.self) { item in
                            VStack {
                                Text(item.iTunesTitle ?? "No Title")
                                Text(item.iTunesSubtitle ?? "No SubTitle")
                                if let downloadProgress = item.downloadProgress {
                                    ProgressView(downloadProgress)
                                }
                            }
//                            NavigationLink(destination: DownloadDetailsView(item: item),
//                                           label: { FeedItemCellView(item: item) } )
                        }
                    }
                }
            }
            .navigationTitle("Downloads")
            // add view to show in split view of iPad
            Text("Select something in Downloads view")
        }
        .onAppear(perform: downloadsBrain.resetStateToIdleIfNeeded)
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsView()
    }
}
