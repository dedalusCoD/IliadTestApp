//
//  CountriesViewControllerViewController.swift
//  IliadTestApp
//
//  Created by Samith on 18/07/23.
//

import UIKit
import Foundation
import ProgressHUD

protocol CountriesView: AnyObject {
    var countries: [Country]? {get set}
    
    func showMessage(title: String, message: String)
    func reloadView()
    func showLoading(text: String)
    func hideLoading()
    func showFilteredList(countries: [Country])
}

class CountriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: CountriesViewModel?
    var rootViewController: UIViewController?
    
    var countries: [Country]?
    var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CountriesViewModel(view: self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "countryDetail" {
            if let viewController = segue.destination as? CountryDetailViewController {
                if let country = sender as? Country {
                    viewController.country = country
                    viewController.flagImage = country.flagImage
                } else {
                    viewController.country = countries?.first(where: { country in
                        country.continents.contains("Europe")
                    })
                }
            }
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.viewModel?.downloadInformation()
    }
    
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Filter countries for", message: "", preferredStyle: UIAlertController.Style.alert)

        let searchForCurrencyAction = UIAlertAction(title: "Currency", style: UIAlertAction.Style.default, handler: { alert -> Void in
            self.dismiss(animated: true) {
                self.searchForCurrency()
            }
        })
        
        let searchForLanguageAction = UIAlertAction(title: "Language", style: UIAlertAction.Style.default, handler: { alert -> Void in
            self.dismiss(animated: true) {
                self.searchForLanguage()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })

        
        alertController.addAction(searchForCurrencyAction)
        alertController.addAction(searchForLanguageAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func searchForCurrency() {
        let alertController = UIAlertController(title: "Filter countries for", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter currency (es. USD)"
        }
        let searchAction = UIAlertAction(title: "Search", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            self.viewModel?.filterByCurrency(currency: textField.text ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func searchForLanguage() {
        let alertController = UIAlertController(title: "Filter countries for", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter language (es. English)"
        }
        let searchAction = UIAlertAction(title: "Search", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            self.viewModel?.filterByLanguage(language: textField.text ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })

        
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }


    @objc func onRightLeftClick(_ sender: UIBarButtonItem){
        rootViewController?.dismiss(animated: true)
    }
    
}

extension CountriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CountryTableViewCell
        cell.flagImageView.image = countries?[indexPath.row].flagImage
        cell.countryNameLabel.text = countries?[indexPath.row].common
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "countryDetail", sender: countries?[indexPath.row])
    }
    
    
}

extension CountriesViewController: CountriesView {
    
    func showMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLoading(text: String) {
        ProgressHUD.show(text)
        self.view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        ProgressHUD.dismiss()
        self.view.isUserInteractionEnabled = true
    }
    
    func reloadView() {
        tableView.reloadData()
    }
    
    func showFilteredList(countries: [Country]) {
        rootViewController = self
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newCountriesViewController = storyboard.instantiateViewController(withIdentifier: "countriesViewController") as! CountriesViewController
        newCountriesViewController.countries = countries
        newCountriesViewController.navigationItem.rightBarButtonItem?.isHidden = true
        let barButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.onRightLeftClick(_ :)))
        newCountriesViewController.navigationItem.rightBarButtonItem = barButtonItem
        newCountriesViewController.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: newCountriesViewController)
        self.present(navController, animated: true)
    }
}

