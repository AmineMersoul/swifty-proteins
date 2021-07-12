//
//  Api.swift
//  swifty-proteins
//
//  Created by Amine Mersoul on 7/12/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import Foundation

class Api {
    
    static let app: Api = {
        return Api()
    }()
    
    
    func getpdbFile(pdbFile: String, completion: @escaping (String) -> ()) {
        let url = URL(string: "https://files.rcsb.org/ligands/\(pdbFile.prefix(1))/\(pdbFile)/\(pdbFile)_ideal.pdb")
        
        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url!)
        request.httpMethod = "GET" //set http method as POST
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            let text = String(decoding: data, as: UTF8.self)
            .components(separatedBy: "\n")
            let pdbContent = text.joined(separator: "\n")
            completion(pdbContent)
        })
        task.resume()
    }
}
