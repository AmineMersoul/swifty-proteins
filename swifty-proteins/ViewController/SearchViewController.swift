//
//  SearchViewController.swift
//  swifty-proteins
//
//  Created by Amine Mersoul on 7/7/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    let data = ["001", "011", "031", "041", "04G", "083", "0AF", "0DS", "0DX", "0E5", "0EA", "0J0", "0JV", "0L8", "0MC", "0MD", "0RU", "0RY"]
    var filtredData: [String]!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        filtredData = data
        
        // set custom cell to table view
        let skillNib = UINib(nibName: "LigandsTableViewCell", bundle: nil)
        tableView.register(skillNib, forCellReuseIdentifier: "LigandsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you selected a cell: \(filtredData[indexPath.row])")
        performSegue(withIdentifier: "showScene", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let ligandsCell = tableView.dequeueReusableCell(withIdentifier: "LigandsTableViewCell", for: indexPath) as! LigandsTableViewCell
         ligandsCell.name?.text = filtredData[indexPath.row]
         return ligandsCell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtredData = []
        
        if (searchText == "" ) {
            filtredData = data
        } else {
            for ligand in data {
                if (ligand.lowercased().contains(searchText.lowercased())) {
                    filtredData.append(ligand)
                }
            }
        }
        self.tableView.reloadData()
    }

}
