//
//  DownloadsBrain.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 22.02.21.
//

import Combine
import FeedKit
import Foundation

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
    private var urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)

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

        try? FileManager.default.createDirectory(at: DownloadItem.localAudioDirURL!, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(at: DownloadItem.localMetadataDirURL!, withIntermediateDirectories: true, attributes: nil)

        guard let urlStr = item.media?.mediaContents?.first?.attributes?.url,
              let url = URL(string: urlStr) else { return }
        di.state = .downloading
        let task = urlSession
            .downloadTask(with: url, completionHandler: { [weak self] (path, response, error) in
                DispatchQueue.main.async { [weak self] in
                    if let downloadPath = path,
                       let localURL = di.localAudioURL {
                        print("Downloaded at: " + downloadPath.absoluteString)
                        print("Will move to: " + localURL.absoluteString)
                        do {
                            try FileManager.default.moveItem(at: downloadPath, to: localURL)
                            try di.save()
                            di.downloadProgress = nil
                            if let index = self?.downloadItems.firstIndex(of: di) {
                                self?.downloadItems.remove(at: index)
                            }
                            self?.scanDownloads()
                        }
                        catch {
                            print("Error during moving file \(error)")
                        }
                    }
                }
            })
//        let progressObserver = task.progress
//            .publisher(for: \.fractionCompleted)
//            .receive(on: RunLoop.main)
//            .sink { (downloadFraction) in
//                print(downloadFraction)
//                di.downloadFraction = downloadFraction
//            }
//        observationItems.append(progressObserver)
        di.downloadProgress = task.progress
        task.resume()
    }

    func scanDownloads() {
        state = .scanningDownloads

        downloadItems = downloadItems.filter { (di) -> Bool in
            di.state != .downloaded
        }

        if let localMetadataURL = DownloadItem.localMetadataDirURL,
           let fileNames = try? FileManager.default.contentsOfDirectory(atPath: localMetadataURL.path) {
            for fileName in fileNames {
                if let di = DownloadItem.decode(fileName: fileName) {
                    downloadItems.append(di);
                }
            }
        }
        state = .showDownloads
    }

    func resetStateToIdleIfNeeded() {
        if case State.showDownloads = state {
            state = .idle
        }
    }
}
