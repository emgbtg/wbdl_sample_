//
//  Networking.swift
//  WBDL_Sample
//
//  Created by Eric Gilbert on 10/10/18.
//  Copyright © 2018 Eric Gilbert. All rights reserved.
//

import Foundation
import CommonCrypto

class Networking {
    
    var pubKey = "14d1b0a1a810fcbc99316e8a9560e284"
    var privKey = "03cb006270c462eea57919265558dedddbd0916d"
    var comics: [Comic] = []
    var seriesComics: [SeriesComics] = []
    var totalCount: Int!
    
    func getComics( dataLoadedCallbackFunction: (() -> Void)?) {
        let urlString = createURL(endpoint: "https://gateway.marvel.com/v1/public/comics") + "&dateDescriptor=thisMonth"
        if let url = NSURL(string: urlString) {
            var request = URLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                
                do{
                    if let comicObject = try? JSONDecoder().decode(ComicResult.self, from: data) {
                        if comicObject.data.results.count > 0 {
                            self.comics = comicObject.data.results
                        }
                        //total count used for infinite scrolling offset calculation
                        self.totalCount = comicObject.data.total
                        
                        if dataLoadedCallbackFunction != nil {
                            DispatchQueue.main.async(execute: {
                                dataLoadedCallbackFunction!()
                            })
                        }
                    }
                    
                }
            }
            task.resume()
            
        }
    }
    func createURL(endpoint:String) -> String {
        let timestamp = NSDate().timeIntervalSince1970
        let hash = self.md5(String(timestamp) + self.privKey + self.pubKey)
        let urlString =  endpoint + "?apikey=" + pubKey + "&hash=" + hash + "&ts=" + String(timestamp)
        
        return urlString
    }
    
    func getComicDetials(comic: Comic, dataLoadedCallbackFunction: (() -> Void)?) {
       // let operation1 = BlockOperation{
            
         //   func getSeies() {
               // if comic.series.resourceURI != nil {
                    let urlString = self.createURL(endpoint: comic.series.resourceURI)
                    if let url = NSURL(string: urlString) {
                        var request = URLRequest(url: url as URL)
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.httpMethod = "GET"
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data, error == nil else {
                                print("error=\(String(describing: error))")
                                return
                            }
                            
                            do{
                                if let seriesObject = try? JSONDecoder().decode(SeriesResult.self, from: data) {
//                                    if seriesObject.data.seriesResults.comics.items.count > 0 {
//                                        self.seriesComics = seriesObject.data.results.comics.items
//                                    }

                                    if dataLoadedCallbackFunction != nil {
                                        DispatchQueue.main.async(execute: {
                                            dataLoadedCallbackFunction!()
                                        })
                                    }
                                }
                                
                            }
                        }
                        task.resume()
                        
                    //}
                }
                
          //  }
            
            func getCharacters() {
            }
            
            func getCreators() {
                
            }
            
       // }
        
//        let operation2 = BlockOperation {
//            print("yay")
//            // Now, operation2 will fire off once operation1 has completed, with results for artists, tracks and albums
//        }
//        operation2.addDependency(operation1)
    }
    
    // function to create an md5 hash string for api authentication
    func md5(_ string: String) -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
}
