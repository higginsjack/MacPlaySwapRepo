
/* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     Apple music add playlist to library
     
     Take spotify songs and add them t
     
     findAppleSong(var spotify_song){
        return apple music song
     }
     
     createApplePlaylist{
        spotify_songs[]
        apple_songs[]
        for... {
            apple_songs[i] = findAppleSong(spotify_song[i])
     
        }
        struct playlist{
            name: PlaySwap001
            tracks {
                apple_songs
            }
        }
        Post(user, playlist)
     }
     */
//
    func findAppleSong(searchTerm: String)->String { //Searches songs and returns the id
        //you can change this to different countries
        let tmpStoreFront = "us"
            print("https://api.music.apple.com/v1/catalog/\(tmpStoreFront)/search?term=\((searchTerm.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "") as! String)&types=songs&limit=5") //changed to songs
            let musicURL = URL(string: "https://api.music.apple.com/v1/catalog/\(tmpStoreFront)/search?term=\((searchTerm.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "") as! String)&types=songs&limit=5")! //changed to songs
    //        print("requesting url: \(musicURL)")
                    var musicRequest = URLRequest(url: musicURL)
                    musicRequest.httpMethod = "GET"
            musicRequest.addValue("Bearer \(self.developerToken)", forHTTPHeaderField: "Authorization")
//            musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")

            URLSession.shared.dataTask(with: musicRequest) { [self] (data, response, error) in
                        guard error == nil else { return }
                        if let json = try? JSON(data: data!) {
//                            print(json)

                            if((json["results"]["songs"]["data"]).array != nil) { //changed to song
                                self.appleMusicSearchResults.removeAll()
                                let result = (json["results"]["songs"]["data"]).array!
                                let attributes = result["attributes"]
                                let currentSong = AppleMusicSong(id: attributes["playParams"]["id"].string ?? "", name: attributes["name"].string ?? "", artistName: attributes["curatorName"].string ?? "", artworkURL: attributes["artwork"]["url"].string ?? "", length:  TimeInterval(Double(0)))
                                return(result[0][0]["id"]) //returns top of search id
//                                for song in result {
//                                    let attributes = song["attributes"]
//                                    let currentSong = AppleMusicSong(id: attributes["playParams"]["id"].string ?? "", name: attributes["name"].string ?? "", artistName: attributes["curatorName"].string ?? "", artworkURL: attributes["artwork"]["url"].string ?? "", length:  TimeInterval(Double(0)))
//        //                            songs.append(currentSong)
//                                    self.appleMusicSearchResults.append(currentSong)
//                                }
                                DispatchQueue.main.async {
                                    self.searchResultsViewController.reloadData()
//                                    self.searchResultsViewController.fadeIn()
                                }
                            }


                        } else {
                            return "ERROR_NO_RESULT"
    //                        lock.signal()
                        }
                    }.resume()


    }
//class MPMediaPlaylist : MPMediaItemCollection
//class MPMediaLibrary : NSObject
//func addItem(withProductID productID: String, completionHandler: (([MPMediaEntity], Error?) -> Void)? = nil)

    func createApplePlaylist(completion: @escaping (Result<Bool>) -> Void)) {
        var components = URLComponents()
        components.path = MKURLComponent.libraryPlaylistsPath
    
        let params: [String: Any] = [
            "attributes":[
                "name": favoritesPlaylistName
            ]
            "tracks": [
        
            ]
        ]
    
        Alamofire.request(components.url(relativeTo: baseUrl)!,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: defaultHeaders())
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    
        //what is spotify playlist
        //convert spotify song to search term send to findAppleSong()
        //add result to apple_songs
        
        addItem(withProductID productID: String, completionHandler: (([MPMediaEntity], Error?) -> Void)? = nil)
    }

    public func addSong(song: Song) {
            let api = MusicKitApi()
            let requestTrack = LibraryPlaylistRequestTrack(id: song.id, type: .songs)
            api.favoritesPlaylist { (result) in
                switch result {
                case .success(let playlist):
                    api.addTrack(track: requestTrack, playlistId: playlist.id, completion: { (result) in
                        switch result {
                        case .success(let success):
                            if success {
                                FavoritesManager.shared.favorites.append(song)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    })
                case .failure(let error):
                    print(error)
                }
            }
        }

/*
 public func addFavoritesPlaylist(completion: @escaping (Result<Bool>) -> Void) {
         var components = URLComponents()
         components.path = MKURLComponent.libraryPlaylistsPath

         let params: [String: Any] = [
             "attributes":[
                 "name": favoritesPlaylistName
             ]
         ]

         Alamofire.request(components.url(relativeTo: baseUrl)!,
                           method: .post,
                           parameters: params,
                           encoding: JSONEncoding.default,
                           headers: defaultHeaders())
             .validate()
             .responseJSON { response in
                 switch response.result {
                 case .success(_):
                     completion(.success(true))
                 case .failure(let error):
                     completion(.failure(error))
                 }
         }
     }
 
 */

/* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
