//
//  DownloadItem.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 28.02.21.
//

import Combine
import Foundation

/*
 Folder:
 Metadata folder - /metadata/ files to keep info about mp3
 Downloads folder - /mp3/ actual mp3 files
 */

class DownloadItem: ObservableObject, Codable {

    enum State {
        case initial
        case downloading
        case downloaded
    }

    struct Constants {
        static let audioDirectory = "audio"
        static let metadataDirectory = "metadata"
        static let metadataExtension = "meta"
    }
    // UUID?????
    var iTunesTitle: String?
    var iTunesSubtitle: String?
    var iTunesDuration: TimeInterval?
    var iTunesSeason: Int?
    var iTunesImageUrl: String?
    var remoteURL: String?

    var observationItems = [AnyCancellable?]()

    @Published var downloadProgress: Progress?
    @Published var state: State = .initial

    enum CodingKeys: String, CodingKey {
        case iTunesTitle
        case iTunesSubtitle
        case iTunesDuration
        case iTunesSeason
        case iTunesImageUrl
        case remoteURL
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        iTunesTitle = try values.decodeIfPresent(String.self, forKey: .iTunesTitle)
        iTunesSubtitle = try values.decodeIfPresent(String.self, forKey: .iTunesSubtitle)
        iTunesDuration = try values.decodeIfPresent(TimeInterval.self, forKey: .iTunesDuration)
        iTunesSeason = try values.decodeIfPresent(Int.self, forKey: .iTunesSeason)
        iTunesImageUrl = try values.decodeIfPresent(String.self, forKey: .iTunesImageUrl)
        remoteURL = try values.decodeIfPresent(String.self, forKey: .remoteURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(iTunesTitle, forKey: .iTunesTitle)
        try container.encodeIfPresent(iTunesSubtitle, forKey: .iTunesSubtitle)
        try container.encodeIfPresent(iTunesDuration, forKey: .iTunesDuration)
        try container.encodeIfPresent(iTunesSeason, forKey: .iTunesSeason)
        try container.encodeIfPresent(iTunesImageUrl, forKey: .iTunesImageUrl)
        try container.encodeIfPresent(remoteURL, forKey: .remoteURL)
    }
}

extension DownloadItem {
    // Path to audio dir
    static var localAudioDirURL: URL? {
        return FileManager
            .default
            .getDocumentsDirectory()
            .appendingPathComponent(Constants.audioDirectory)
    }
    // Audio file name
    var audioFileName: String? {
        if let remoteURLLocal = remoteURL,
           let lastPathComponent = URL(string: remoteURLLocal)?.lastPathComponent {
            return String(remoteURLLocal.hash) + "_" + lastPathComponent
        }
        return nil
    }
    // Path audio file based on path to audio dir and audio file name
    var localAudioURL: URL? {
        if let audioFileName = audioFileName {
            return Self
                .localAudioDirURL?
                .appendingPathComponent(audioFileName)
        }
        return nil
    }

    // Path to metadata dir
    static var localMetadataDirURL: URL? {
        return FileManager
            .default
            .getDocumentsDirectory()
            .appendingPathComponent(Constants.metadataDirectory)
    }
    // Metadata file name
    var metadataFileName: String? {
        if let remoteURL = remoteURL,
           let lastPathComponent = URL(string: remoteURL)?.deletingPathExtension().lastPathComponent {
            return String(remoteURL.hash) + "_" + lastPathComponent + "." + Constants.metadataExtension
        }
        return nil
    }
    // Path metadata file based on path to metadata dir and metadata file name
    var localMetadataURL: URL? {
        if let metadataFileName = metadataFileName {
            return Self
                .localMetadataDirURL?
                .appendingPathComponent(metadataFileName)
        }
        return nil
    }
}

extension DownloadItem {
    // Save this item to localMetadataURL
    func save() throws {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let localMetadataURL = localMetadataURL {
            try data.write(to: localMetadataURL)
        }
    }
    // Delete this item from localMetadataURL
    func delete() throws {
        if let localAudioURL = localAudioURL {
            try FileManager.default.removeItem(at: localAudioURL)
        }
        if let localMetadataURL = localMetadataURL {
            try FileManager.default.removeItem(at: localMetadataURL)
        }
    }

    static func decode(fileName: String) -> DownloadItem? {
        if let url = DownloadItem.localMetadataDirURL?.appendingPathComponent(fileName),
           let data = try? Data(contentsOf: url),
           let di = try? JSONDecoder().decode(DownloadItem.self, from: data) {
            di.state = .downloaded
            return di
        }
        return nil
    }
}

extension DownloadItem: Hashable {
    static func == (lhs: DownloadItem, rhs: DownloadItem) -> Bool {
        return lhs.iTunesTitle == rhs.iTunesTitle
    }

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

fileprivate extension FileManager {
    func getDocumentsDirectory() -> URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
