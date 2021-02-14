//
//  FeedItemCellView.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 13.02.21.
//

import FeedKit
import SwiftUI

struct FeedItemCellView: View {
    let item: RSSFeedItem
    var body: some View {
        HStack {
            ImageFromURLView(imageLoader: ImageLoader(urlString: item.iTunes?.iTunesImage?.attributes?.href))
            Text(item.title ?? "")
        }
    }
}

struct FeedItemCellView_Previews: PreviewProvider {
    static var previews: some View {
        FeedItemCellView(item: RSSFeedItem())
    }
}
