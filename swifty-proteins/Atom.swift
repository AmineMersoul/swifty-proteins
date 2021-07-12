//
//  Atom.swift
//  swifty-proteins
//
//  Created by Amine Mersoul on 7/12/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import Foundation

struct Elements : Decodable {
    let elements: [AtomInfo]?
}

struct AtomInfo: Decodable {
    let name: String?
    let phase: String?
    let summary: String?
    let symbol: String?
}

class GetAtomInfo {
    
    func getInfo() -> Elements? {
        var jsonResult:Elements? = nil
        if let path = Bundle.main.path(forResource: "PeriodicTable", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                jsonResult = try JSONDecoder().decode(Elements.self, from: data) as Elements?
                return jsonResult
            } catch {
                print("error vse dela")
            }
        }
        return jsonResult
    }
}
