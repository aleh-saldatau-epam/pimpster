//
//  PlayableItem.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 1.03.21.
//

import FeedKit
import Foundation

protocol PlayableItem {
    var urlToPlayFrom: URL? { get }
    var title: String? { get }
    var description: String? { get }
    var imageUrlString: String? { get }
}

extension RSSFeedItem: PlayableItem {
    var urlToPlayFrom: URL? {
        let url = media?.mediaContents?.first?.attributes?.url
        print( url ?? "No url")
        guard let urlString = url,
              let actualURL = URL(string: urlString) else {
            return nil
        }
        return actualURL
    }
    var imageUrlString: String? { iTunes?.iTunesImage?.attributes?.href }
}

extension DownloadItem: PlayableItem {
    var urlToPlayFrom: URL? { localAudioURL }
    var title: String? { iTunesTitle }
    var description: String? { iTunesSubtitle }
    var imageUrlString: String? { iTunesImageUrl }
}
