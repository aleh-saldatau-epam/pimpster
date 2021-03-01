//
//  FeedItemDetailsView.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 13.02.21.
//

import FeedKit
import SwiftUI

struct FeedItemDetailsView: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    @EnvironmentObject var itemDownloadingBrain: DownloadsBrain
    @Environment(\.presentationMode) var presentationMode
    let item: RSSFeedItem
    var body: some View {
        VStack {
            HStack {
                Text("Title: ")
                Text(item.iTunes?.iTunesTitle ?? "")
            }
            HStack {
                Text("Description: ")
                Text(item.iTunes?.iTunesSubtitle ?? "")
            }
            HStack {
                Text("Duration: ")
                Text(DateComponentsFormatter().string(from: item.iTunes?.iTunesDuration ?? 0) ?? "")
            }
            HStack {
                Text("Season: ")
                Text(String(item.iTunes?.iTunesSeason ?? 0))
            }
            HStack {
                Text("URL: ")
                Text(item.media?.mediaContents?.first?.attributes?.url ?? "")
            }
            Button("Play") {
                playerBrain.playableItem = item
            }
            Button("Download") {
                itemDownloadingBrain.download(item: item)
            }
        }
    }
}

struct FeedItemDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        FeedItemDetailsView(item: RSSFeedItem())
    }
}
