//
//  RootView.swift
//  Shared
//
//  Created by Oleg Soldatoff on 11.02.21.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            FeedView()
                .modifier(StickyPlayerViewModifier())
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Feed")
                }

            DownloadsView()
                .modifier(StickyPlayerViewModifier())
                .tabItem {
                    Image(systemName: "icloud.and.arrow.down")
                    Text("Downloads")
                }
            Text("The Last Tab")
                .modifier(StickyPlayerViewModifier())
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Third")
                }
        }
//        .overlay(StickyPlayerView())
        .font(.headline)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
