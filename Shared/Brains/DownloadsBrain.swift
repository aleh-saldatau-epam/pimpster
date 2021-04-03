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

    func download(item: RSSFeedItem) {
        let di = DownloadItem()
        di.iTunesTitle = item.iTunes?.iTunesTitle
        di.iTunesSubtitle = item.iTunes?.iTunesSubtitle
        di.iTunesDuration = item.iTunes?.iTunesDuration
        di.iTunesSeason = item.iTunes?.iTunesSeason
        di.iTunesImageUrl = item.iTunes?.iTunesImage?.attributes?.href
        di.remoteURL = item.media?.mediaContents?.first?.attributes?.url

        downloadItems.append(di)

        // TODO: Check number of downloads!!!
        // TODO: Resume logic!!

        try? FileManager.default.createDirectory(at: DownloadItem.localAudioDirURL!, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(at: DownloadItem.localMetadataDirURL!, withIntermediateDirectories: true, attributes: nil)

        guard let urlStr = item.media?.mediaContents?.first?.attributes?.url,
              let url = URL(string: urlStr) else { return }
        di.state = .downloading
        let task = URLSession
            .shared
            .downloadTask(with: url, completionHandler: { [weak self] (path, response, error) in
                var finalState = DownloadItem.State.downloaded
                defer {
                    DispatchQueue.main.async { [weak self] in
                        di.downloadProgress = nil
                        di.state = finalState
                        if let index = self?.downloadItems.firstIndex(of: di) {
                            self?.downloadItems.remove(at: index)
                        }
                        self?.scanDownloads()
                    }
                }
                if let downloadPath = path,
                   let localURL = di.localAudioURL {
                    print("Downloaded at: " + downloadPath.absoluteString)
                    print("Will move to: " + localURL.absoluteString)
                    do {
                        try FileManager.default.moveItem(at: downloadPath, to: localURL)
                        try di.save()
                        finalState = DownloadItem.State.downloaded
                    }
                    catch {
                        print("Error during moving file \(error)")
                        finalState = DownloadItem.State.initial
                    }
                }
            })
        di.downloadProgress = Progress()
        let progressObserver = task.progress
            .publisher(for: \.fractionCompleted)
            .receive(on: RunLoop.main)
            .sink { (downloadFraction) in
                print("downloadFraction: \(downloadFraction)")
                /*
                po task.progress.userInfo
                ▿ 4 elements
                  ▿ 0 : 2 elements
                    ▿ key : NSProgressUserInfoKey
                      - _rawValue : NSProgressFileOperationKindKey
                    - value : NSProgressFileOperationKindDownloading
                  ▿ 1 : 2 elements
                    ▿ key : NSProgressUserInfoKey
                      - _rawValue : NSProgressFileURLKey
                    - value : https://traffic.libsyn.com/swiftbysundell/SwiftBySundell89.mp3
                  ▿ 2 : 2 elements
                    ▿ key : NSProgressUserInfoKey
                      - _rawValue : NSProgressByteCompletedCountKey
                    - value : 1441792
                  ▿ 3 : 2 elements
                    ▿ key : NSProgressUserInfoKey
                      - _rawValue : NSProgressByteTotalCountKey
                    - value : 53566934
                 */

//                if let totalUnitCount = task.progress.userInfo[ProgressUserInfoKey(rawValue: "NSProgressByteTotalCountKey")] as? Int64 {
//                    di.downloadProgress?.totalUnitCount = totalUnitCount
//                }
//                if let completedUnitCount = task.progress.userInfo[ProgressUserInfoKey(rawValue: "NSProgressByteCompletedCountKey")] as? Int64 {
//                    di.downloadProgress?.completedUnitCount = completedUnitCount
//                }

                di.downloadProgress?.completedUnitCount = Int64(downloadFraction * 1000000)
                di.downloadProgress?.totalUnitCount = Int64(1000000)

                di.downloadProgress?.localizedDescription = task.progress.localizedDescription
                di.downloadProgress?.localizedAdditionalDescription = task.progress.localizedAdditionalDescription

            }
        di.observationItems.append(progressObserver)

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
