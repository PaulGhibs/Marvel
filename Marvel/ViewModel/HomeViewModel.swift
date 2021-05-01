//
//  HomeViewModel.swift
//  Marvel
//
//  Created by Paul Ghibeaux on 30/04/2021.
//

import SwiftUI
import Combine

import CryptoKit

class HomeViewModel: ObservableObject{
    
    @Published var searchQuery = ""
    
     //combine framework search bar
    
    // use to cancel searchbar publisher when ever we need ...
    
    // comic view data ....
    @Published var fetchedComics: [Comic] = []
    @Published var offset: Int = 0
    
    var searchCancellable : AnyCancellable? = nil
    
    // fetch data
    
    @Published var fetchedCharacters: [Character]? = nil
    
    init() {
        
        searchCancellable = $searchQuery
            
            .removeDuplicates()
            
            .debounce(for: 0.6, scheduler: RunLoop.main)
            .sink(receiveValue: { str in
                if str == "" {
                    //reset data ...
                    self.fetchedCharacters = nil
                    
                } else {
                    // search data
                    self.searchCharacter()

                }
            })
        
    }
    
    func searchCharacter() {
        let ts = String(Date().timeIntervalSince1970)
        let hash = MD5(data: "\(ts)\(privatekey)\(publicKey)")
        let originalQuery = searchQuery.replacingOccurrences(of: " ", with: " %20")
        let url =  "https://gateway.marvel.com:443/v1/public/characters?nameStartsWith=\(originalQuery)&ts=\(ts)&apikey=\(publicKey)&hash=\(hash)"
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { data, _, err in
            
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            guard let APIData = data else {
                print("no data found")
                return
            }
            do{
                // decoding api data
                let characters = try JSONDecoder().decode(APIResult.self, from: APIData)
                DispatchQueue.main.async {
                    if self.fetchedCharacters == nil {
                        self.fetchedCharacters = characters.data.results
                        
                    }
                }
            }
            
            catch{
                print(error.localizedDescription)
            }
        }
        .resume()
    }
    
    // crypto kit for hash
    
    func MD5(data : String)-> String {
        let hash = Insecure.MD5.hash(data: data.data(using: .utf8) ?? Data())
        return hash.map{
            String(format: "%02hhx", $0)
            
        }
        .joined()
    }
    
    
    func fetchComics() {
        let ts = String(Date().timeIntervalSince1970)
        let hash = MD5(data: "\(ts)\(privatekey)\(publicKey)")
        
        let url =  "https://gateway.marvel.com:443/v1/public/comics?limit=20&offset=\(offset)&ts=\(ts)&apikey=\(publicKey)&hash=\(hash)"
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { data, _, err in
            
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            guard let APIData = data else {
                print("no data found")
                return
            }
            do{
                // decoding api data
                let comic = try JSONDecoder().decode(APIComicResult.self, from: APIData)
                DispatchQueue.main.async {
       
                    self.fetchedComics.append(contentsOf: comic.data.results)
                }
            }
            
            catch{
                print(error.localizedDescription)
            }
        }
        .resume()
    }
}
