//
//  DownloadsBrain.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 22.02.21.
//

import Combine
import FeedKit
import Foundation

/*
 Folder:
 Metadata folder - *.??? files to keep info about mp3
 Downloads folder - *.mp3 actual mp3 files
 */


class DownloadItem: ObservableObject {
    // UUID?????
    var iTunesTitle: String?
    var iTunesSubtitle: String?
    var iTunesDuration: TimeInterval?
    var iTunesSeason: Int?
    var remoteURL: String?
    var localURL: String?
    @Published var downloadProgress: Progress?
}

extension DownloadItem: Hashable {
    static func == (lhs: DownloadItem, rhs: DownloadItem) -> Bool {
        return lhs.iTunesTitle == rhs.iTunesTitle
    }

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

class DownloadsBrain: ObservableObject {

    enum State {
        case idle
        case scanningDownloads
        case emptyDownloads
        case showDownloads
    }

    @Published private(set) var state = State.idle
    @Published private(set) var downloadItems: [DownloadItem] = [DownloadItem]()

    private var observationItems = [AnyCancellable?]()

    func download(item: RSSFeedItem) {
        let di = DownloadItem()
        di.iTunesTitle = item.iTunes?.iTunesTitle
        di.iTunesSubtitle = item.iTunes?.iTunesSubtitle
        di.iTunesDuration = item.iTunes?.iTunesDuration
        di.iTunesSeason = item.iTunes?.iTunesSeason
        di.remoteURL = item.media?.mediaContents?.first?.attributes?.url

        downloadItems.append(di)

        // TODO: Check number of downloads!!!
        // TODO: Resume logic!!
        guard let urlStr = item.media?.mediaContents?.first?.attributes?.url,
              let url = URL(string: urlStr) else { return }
        let task = URLSession.shared
            .downloadTask(with: url, completionHandler: { (path, response, error) in
                print(path)
            })
        let progressObserver = task.progress
            .publisher(for: \.fractionCompleted)
            .sink { (progress) in
                print(progress)
            }
        observationItems.append(progressObserver)
        di.downloadProgress = task.progress
        task.resume()
    }

    func scanDownloads() {
        state = .showDownloads
    }

    func resetStateToIdleIfNeeded() {
        if case State.showDownloads = state {
            state = .idle
        }
    }
}
