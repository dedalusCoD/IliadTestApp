//
//  CountryDetailViewController.swift
//  IliadTestApp
//
//  Created by Samith on 18/07/23.
//

import UIKit
import Foundation


class CountryDetailViewController: UIViewController {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var country: Country?
    var flagImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = country?.common
        flagImageView.image = flagImage
    }
    
}

extension CountryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        switch indexPath.row {
        
        case 0:
            cell.textLabel?.text = "Common Name"
            cell.detailTextLabel?.text = country?.common
        case 1:
            cell.textLabel?.text = "Official Name"
            cell.detailTextLabel?.text = country?.officialName
        case 2:
            cell.textLabel?.text = "Capitals"
            cell.detailTextLabel?.text = country?.capitals.joined(separator: ",")
        case 3:
            cell.textLabel?.text = "Continent"
            cell.detailTextLabel?.text = country?.continents.joined(separator: ",")
        case 4:
            cell.textLabel?.text = "Subregion"
            cell.detailTextLabel?.text = country?.subRegion
        case 5:
            cell.textLabel?.text = "Population"
            cell.detailTextLabel?.text = "\(country?.population ?? 0)"
            
        default:
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    
}


