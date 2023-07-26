//
//  CountriesViewModel.swift
//  IliadTestApp
//
//  Created by Samith on 18/07/23.
//

import Foundation
import Alamofire
import UIKit

let basePath = "http://restcountries.com/v3.1/"
let allInformationUrlComponent = "all"
let languageUrlComponent = "lang/"
let currencyUrlComponent = "currency/"

protocol CountriesViewModelProtocol {
    func downloadInformation()
    
}

class CountriesViewModel: CountriesViewModelProtocol {
    
    weak var view: CountriesView?
    var totalCountries: Int?
    
    init(view: CountriesView) {
        self.view = view
        if self.view?.countries?.count == nil {
            downloadInformation()
        }
    }
    
    func downloadInformation() {
        self.view?.showLoading(text: "Downloading information")
        
        AF.request(basePath + allInformationUrlComponent).response { response in
            debugPrint(response)
            
            switch response.result {
            case .success(let data) :
                guard let responseData = data, response.response?.statusCode == 200 else {
                    self.view?.hideLoading()
                    self.view?.showMessage(title: "Impossible to retrieve data from the server", message: "Please try again later")
                    return
                }
                
                self.view?.countries = []
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: [])  {
                    if let objectList = json as? [NSDictionary] {
                        self.totalCountries = objectList.count
                        for element in objectList {
                            let name = element[CountryJsonKey.name.rawValue] as? NSDictionary
                            let flagsInfo = element[CountryJsonKey.flags.rawValue] as? NSDictionary
                            
                            let common = name?[CountryJsonKey.common.rawValue] as? String
                            let officialName = name?[CountryJsonKey.official.rawValue] as? String
                            
                            var capitals: [String] = []
                            if let capitalsToSave = element[CountryJsonKey.capital.rawValue] as? [String] {
                                for capital in capitalsToSave {
                                    capitals.append(capital)
                                }
                            }
                            
                            var continents: [String] = []
                            if let continentsToSave = element[CountryJsonKey.continents.rawValue] as? [String]  {
                                for continent in continentsToSave {
                                    continents.append(continent)
                                }
                            }
                            
                            
                            let independent = element[CountryJsonKey.independent.rawValue] as? String
                            let region = element[CountryJsonKey.region.rawValue] as? String
                            let subRegion = element[CountryJsonKey.subregion.rawValue] as? String
                            let population = element[CountryJsonKey.population.rawValue] as? Int64
                            
                            let png = flagsInfo?[FlagJsonKey.png.rawValue] as? String
                            let svg = flagsInfo?[FlagJsonKey.svg.rawValue] as? String
                            let alt = flagsInfo?[FlagJsonKey.alt.rawValue] as? String
                            
                            
                            let flags = Flags(png: png,
                                              svg: svg,
                                              alt: alt)
                                
                            let country = Country(common: common ?? "",
                                                  officialName: officialName,
                                                  capitals: capitals,
                                                  independent: independent == "true" ? true : false,
                                                  continents: continents,
                                                  flags: flags,
                                                  region: region,
                                                  subRegion: subRegion,
                                                  population: population)
                            
                            
                            guard let url = URL(string: png ?? "") else {
                                break
                            }
                            self.downloadImage(from: url, country: country)
                            
                        }
                    }
                }
                
            case .failure(let afError):
                self.view?.hideLoading()
                self.view?.showMessage(title: "Error", message: "No countries found with selected language (\(afError.localizedDescription))")
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, country: Country) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let flagImage = UIImage(data: data) ?? UIImage()
            let newCountry = Country(common: country.common,
                                     officialName: country.officialName,
                                     capitals: country.capitals,
                                     independent: country.independent,
                                     continents: country.continents,
                                     flags: country.flags,
                                     region: country.region,
                                     subRegion: country.subRegion,
                                     population: country.population,
                                     flagImage: flagImage)
            self.view?.countries?.append(newCountry)
            if self.view?.countries?.count == self.totalCountries {
                DispatchQueue.main.async {
                    self.view?.countries?.sort(by: { first, second in
                        first.common < second.common
                    })
                    self.view?.hideLoading()
                    self.view?.reloadView()
                    
                }
            }
        }
    }
    
    func filterByLanguage(language: String) {
        self.view?.showLoading(text: "Please wait")
        AF.request(basePath + languageUrlComponent + language).response { response in
            debugPrint(response)

        switch response.result {
        case .success(let data) :
            guard let responseData = data, response.response?.statusCode == 200 else {
                self.view?.hideLoading()
                self.view?.showMessage(title: "Error", message: "No countries found with selected language")
                return
            }
            
            self.showDecodedFilteredData(data: responseData)
        case .failure(let afError):
            self.view?.hideLoading()
            self.view?.showMessage(title: "Error", message: "No countries found with selected language (\(afError.localizedDescription))")
            }
        }
    }
    
    func filterByCurrency(currency: String) {
        self.view?.showLoading(text: "Please wait")
        AF.request(basePath + currencyUrlComponent + currency).response { response in
            debugPrint(response)
            switch response.result {
            case .success(let data) :
                guard let responseData = data, response.response?.statusCode == 200 else {
                    self.view?.hideLoading()
                    self.view?.showMessage(title: "Error", message: "No countries found with selected currency")
                    return
                }
                
                self.showDecodedFilteredData(data: responseData)
            case .failure(let afError):
                self.view?.hideLoading()
                self.view?.showMessage(title: "Error", message: "No countries found with selected currency (\(afError.localizedDescription))")
            }

        }
    }
    
    func showDecodedFilteredData(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: [])  {
            if let objectList = json as? [NSDictionary] {
                var filteredCountryList: [Country] = []
                
                for element in objectList {
                    let name = element[CountryJsonKey.name.rawValue] as? NSDictionary
                    let common = name?[CountryJsonKey.common.rawValue] as? String
                    
                    guard let filteredCountry = self.view?.countries?.first(where: { country in
                        country.common == common
                    }) else {
                        continue
                    }
                    
                    filteredCountryList.append(filteredCountry)
                    
                }
                self.view?.hideLoading()
                filteredCountryList.sort(by: { first, second in
                    first.common < second.common
                })
                self.view?.showFilteredList(countries: filteredCountryList)
            }
        }
    }
    
    
}
