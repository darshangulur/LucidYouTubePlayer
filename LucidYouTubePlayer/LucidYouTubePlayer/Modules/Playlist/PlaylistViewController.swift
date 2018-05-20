//
//  ViewController.swift
//  LucidPlaylistPlayer
//
//  Created by Darshan Gulur Srinivasa on 4/16/18.
//  Copyright © 2018 Lucid Infosystems. All rights reserved.
//

import UIKit
import TinyConstraints

final class PlaylistViewController: UIViewController {

    // MARK: - Private properties
    private var categories = [String]()
    private var videos: [String: [PlaylistResponse.Item]] = [:]
    
    private lazy var tableView: UITableView = {
        $0.register(PlaylistRow.self, forCellReuseIdentifier: PlaylistRow.className)
        $0.dataSource = self
        $0.delegate = self
        $0.showsVerticalScrollIndicator = false
        $0.separatorStyle = .none
        return $0
    }(UITableView(frame: .zero))

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Playlist"
        self.view.backgroundColor = Stylesheet.Color.primaryWhite

        addSubViews()
        fetchPlaylist()
    }

    // MARK: - Private properties
    private func addSubViews() {
        self.view.addSubview(tableView)
        tableView.edgesToSuperview()
    }
}

extension PlaylistViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView(title: categories[section])
    }

    func numberOfSections(in tableView: UITableView) -> Int { return categories.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistRow.className, for: indexPath) as! PlaylistRow
        cell.configure(items: self.videos[self.categories[indexPath.row]] ?? []) { item in
            let player = YTPlayerViewController(videoId: item.snippet.resourceId.videoId)
            self.navigationController?.present(player, animated: true)
        }
        return cell
    }

}

extension PlaylistViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

fileprivate extension PlaylistViewController {
    private func fetchPlaylist() {
        guard let playlistIds = UserDefaults.standard.stringArray(forKey: "playlistIds") else { return }

        self.categories.removeAll()
        self.videos.removeAll()

        let playlistRepository: PlaylistSourcing = PlaylistRepository()
        playlistIds.forEach {
            let pathString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\($0)&maxResults=50&key=AIzaSyDBK7Rf8Kup64cWymKwMZeAEOS_x_G0gCw"
            playlistRepository.fetchPlaylist(forURL: pathString) { [weak self] playlistResponse in
                guard let response = playlistResponse, let firstItem = response.items.first else { return }

                self?.categories.append(firstItem.snippet.title)
                self?.videos.updateValue(response.items, forKey: firstItem.snippet.title)
                self?.tableView.reloadData()
            }
        }
    }
}
