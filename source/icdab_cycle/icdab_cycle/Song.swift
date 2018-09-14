//
//  Song.swift
//  icdab_cycle
//
//  Created by Faisal Memon on 14/09/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import Foundation

class Song {
    var album: Album
    var artist: String
    var title: String
    
    init(album: Album, artist: String, title: String) {
        self.album = album
        self.artist = artist
        self.title = title
    }
}
