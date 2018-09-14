//
//  ViewController.swift
//  icdab_cycle
//
//  Created by Faisal Memon on 14/09/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var mediaLibrary: [Album]?
    
    func buildMediaLibrary() {
        let kylie = Album()
        let song1 = Song(album: kylie, artist: "Kylie Minogue", title: "It's No Secret")
        kylie.songs?.append(song1)
        mediaLibrary = [kylie]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let firstAlbum = mediaLibrary?.first, let songs = firstAlbum.songs {
            return songs.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell_id") as! SongTableViewCell
        
        if let firstAlbum = mediaLibrary?.first, let songs = firstAlbum.songs {
            cell.songNameLabelOutlet.text = songs[indexPath.row].title
        } else {
            return cell
        }
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
}
