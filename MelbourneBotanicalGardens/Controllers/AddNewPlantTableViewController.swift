//
//  AddNewPlantTableViewController.swift
//  MelbourneBotanicalGardens
//  This controller is used to search plant from API.
//  Created by Sugandh Singhal on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreData

// Followed the tutorial for week 6 for this controller.

class AddNewPlantTableViewController: UITableViewController, UISearchBarDelegate {
    
    // Variables are declared
    let CELL_PLANT = "plantCell"
    let REQUEST_STRING = "https://trefle.io/api/v1/plants/search?token=Re0QCaPXGXNE2CK_olJnG3mYaUEZcw6_x86D635uqVU&q="
    var indicator = UIActivityIndicatorView()
    var newPlant = [PlantData]()
    let MAX_REQUESTS = 10
    var currentRequestPage: Int = 1
    
    
    // This view will load when the screen first appears.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for plants"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return newPlant.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plantSelected = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        let plant = newPlant[indexPath.row]
        plantSelected.textLabel?.text = plant.name
        plantSelected.detailTextLabel?.text = plant.scientificName
        return plantSelected
        
    }
    
    // when new plant is selected we will add that plant and pop another screen.
    override func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath) {
        let plant = newPlant[indexPath.row]
        addPlant(plantData:plant)
        navigationController?.popViewController(animated: true)
        
    }
    
    // Function writen for the search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // If there is no text end immediately
        guard let searchText = searchBar.text, searchText.count > 0 else {
            return
            
        }
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        newPlant.removeAll()
        tableView.reloadData()
        URLSession.shared.invalidateAndCancel()
        currentRequestPage = 0;
        
        requestPlant(plantName: searchText)
        
    }
    
    // Requesting the plant from API. I tried puting some filter but could not make it work so I commented it.
    func requestPlant(plantName: String){
        let searchString = REQUEST_STRING + plantName
        let jsonURL =
            URL(string: searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        /* https://trefle.io/api/v1/plants/search?token=Re0QCaPXGXNE2CK_olJnG3mYaUEZcw6_x86D635uqVU&q=
         var searchURLComponents = URLComponents()
         searchURLComponents.scheme = "https"
         searchURLComponents.host = "trefle.io"
         searchURLComponents.path = "/api/v1/plants/search?token=Re0QCaPXGXNE2CK_olJnG3mYaUEZcw6_x86D635uqVU&"
         searchURLComponents.queryItems = [
         
         URLQueryItem(name: "page", value: "\(currentRequestPage)"),
         URLQueryItem(name: "q", value: plantName)
         ]
         let jsonURL = searchURLComponents.url*/
        
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            // Regardless of response end the loading icon from the main thread
            DispatchQueue.main.async { self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true }
            if let error = error { print(error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(VolumeData.self, from: data!)
                if let plants = volumeData.plants {
                    self.newPlant.append(contentsOf: plants)
                    DispatchQueue.main.async {
                        self.tableView.reloadData() }
                }
                
                
            }
            catch let err {
                print(err) }
        }
        task.resume()
        
    }
    
   // Adding the new plant to the core data.
    func addPlant(plantData: PlantData){
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        let contextManager = appDelegate.persistentContainer.viewContext
        let plantEntity = NSEntityDescription.entity(forEntityName: "Plant", in: contextManager)
        let plantSel = NSManagedObject(entity: plantEntity!, insertInto: contextManager)
        plantSel.setValue(plantData.name, forKey:"name")
        plantSel.setValue(plantData.discoveryYear, forKey: "discoveryYear")
        plantSel.setValue(plantData.family, forKey: "family")
        plantSel.setValue(plantData.scientificName, forKey: "scientificName")
        plantSel.setValue(plantData.url, forKey: "url")
        plantSel.setValue(UUID(), forKey: "id")
        do{
            try contextManager.save()
        }catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
}













