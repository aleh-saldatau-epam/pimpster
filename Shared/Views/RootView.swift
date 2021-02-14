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
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Feed")
                }
            Text("Another Tab")
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Second")
                }
            Text("The Last Tab")
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Third")
                }
        }
        .overlay(StickyPlayerView())
        .font(.headline)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
