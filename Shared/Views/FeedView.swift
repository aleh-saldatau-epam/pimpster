//
//  FeedView.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 11.02.21.
//

import SwiftUI

struct FeedView: View {
    @StateObject var feedBrain = FeedBrain(urlStr: "https://swiftbysundell.com/podcast/feed.rss")
    var body: some View {
        NavigationView {
//            VStack {
            Group {
                switch feedBrain.state {
                case .idle:
                    Color.clear.onAppear(perform: feedBrain.loadFeed)
                case .loading:
                    ProgressView()
                case .failed(_):
                    Text("Error")
                case .loaded:
                    List {
                        ForEach(feedBrain.feed.items ?? [], id: \.self) { item in
                            NavigationLink(destination: FeedItemDetailsView(item: item),
                                           label: { FeedItemCellView(item: item) } )
                        }
                    }
                }
//                StickyPlayerView()
            }
            .navigationTitle(Text(feedBrain.feed.title ?? ""))
            // add view to show in split view of iPad
            Text("Select something in feed view")
        }
        .onAppear(perform: feedBrain.resetStateToIdleIfNeeded)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
