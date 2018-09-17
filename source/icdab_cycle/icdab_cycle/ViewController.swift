//
//  ViewController.swift
//  icdab_cycle
//
//  Created by Faisal Memon on 14/09/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var mediaLibrary: Album?
    
    func createRetainCycleLeak() {
        let salsa = Album()
        let carnaval = Song(album: salsa, artist: "Salsa Latin 100%", title: "La Vida Es un Carnaval")
        salsa.songs.append(carnaval)
    }
    
    func buildMediaLibrary() {
        let kylie = Album()
        let secret = Song(album: kylie, artist: "Kylie Minogue", title: "It's No Secret")
        kylie.songs.append(secret)
        mediaLibrary = kylie
        createRetainCycleLeak()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildMediaLibrary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let firstAlbum = mediaLibrary {
            let songs = firstAlbum.songs
            return songs.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell_id") as! SongTableViewCell
        
        if let firstAlbum = mediaLibrary {
            let songs = firstAlbum.songs
            cell.songNameLabelOutlet.text = songs[indexPath.row].title + " by " + songs[indexPath.row].artist
        } else {
            return cell
        }
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
}
