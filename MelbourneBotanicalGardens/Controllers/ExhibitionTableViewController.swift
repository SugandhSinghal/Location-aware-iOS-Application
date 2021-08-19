//
//  ExhibitionTableViewController.swift
//  MelbourneBotanicalGardens
//  This controller will show the list of all the exhibition, will provide search and sort features.
//  Created by Sugandh Singhal on 6/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit
import CoreData



class ExhibitionTableViewController: UITableViewController, UISearchResultsUpdating, CLLocationManagerDelegate{
    
    
    // variable declaration
    weak var homeScreenViewController: HomeScreenViewController?
    var exhibitionList: [Exhibition] = []
    var filteredexhibitionList = [Exhibition]()
    var flag = true
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This function will fetch all the exhibitions from the core data and store it in exhibitionList
        loadExhibition()
        
        // Reference: Week 3 tutorial
        filteredexhibitionList = exhibitionList
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exhibitions"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        
    }
    
    
    /* Reference: https://medium.com/@nabilaeffath/searching-sorting-data-in-a-table-view-using-xcode-10-swift-4-2-e0d5702d11fb */
    // This button will perform sorting
    @IBAction func exhibitionsSort(_ sender: Any) {
        
        if flag {
            filteredexhibitionList = filteredexhibitionList.sorted(by: { $0.name! > $1.name! })
            self.tableView.reloadData()
            flag = false
        }
        else{
            filteredexhibitionList = filteredexhibitionList.sorted(by: { $0.name! < $1.name! })
            tableView.reloadData()
            flag = true
        }
        
    }
    
    // MARK: - Search Controller Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // By using lowercased I have made it case insensitive but on removing it our search will become case sensitive
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        if searchText.count > 0 {
            filteredexhibitionList = exhibitionList.filter({ (exhibition: Exhibition) -> Bool in
                return (exhibition.name?.lowercased().contains(searchText.lowercased()) ?? false)
            })
        } else {
            filteredexhibitionList = exhibitionList
        }
        
        tableView.reloadData()
    }
    
    
    // retriving data from the core data and storing it into our variable exhibitionList
    // Reference: https://medium.com/@ankurvekariya/core-data-crud-with-swift-4-2-for-beginners-40efe4e7d1cc
    func loadExhibition(){
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        
        let contextManager = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        do {
            let listExhibition  = try contextManager.fetch(fetchRequest)
            exhibitionList = listExhibition
            
        }catch{
            print("Cannot fetch Exhibition")
        }
        
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
      
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return filteredexhibitionList.count
    }
    
    /* Reference: https://www.google.com/search?q=plant+exhibition+thumbnail+image&rlz=1C5CHFA_enAU916AU916&tbm=isch&source=iu&ictx=1&fir=GskeoFUoPkBuAM%252C2iDV3nJmLv5SZM%252C_&vet=1&usg=AI4_-kSgZquUnMnaVkPiIWG0W-48qfVGzw&sa=X&ved=2ahUKEwj6mNb4huLrAhWCeX0KHe0cDioQ9QF6BAgKEAY#imgrc=K_z6CPdH5EDD8M */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExhibitionCell", for:indexPath)as! ExhibitionTableViewCell
        let exhibition = filteredexhibitionList[indexPath.row]
        cell.setNameLabel.textColor = UIColor(named: "ExhibitionLabel")
        cell.setNameLabel.text = exhibition.name
        cell.setDescribeLabel.text = exhibition.describe
        let img = UIImage(named: exhibition.icon!)
        cell.setImageIcon.image = img
        return cell
    }
    
    // on selecting any row it will take us to the map screen that is our HomeScreenViewController
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath){
        
        homeScreenViewController?.getTheSelectedAnnoation = filteredexhibitionList[indexPath.row].id
        if let mapVC = homeScreenViewController {
            splitViewController?.showDetailViewController(mapVC, sender: nil)
        }
    }
    
    // For deleting any Exhibition from the list as well as core data we use this method.
    // Reference: https://medium.com/@ankurvekariya/core-data-crud-with-swift-4-2-for-beginners-40efe4e7d1cc
    override   func tableView(_ tableView: UITableView,
                              trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let action = UIContextualAction(style: .destructive, title: "Delete")
        {(action, view, CLGeocodeCompletionHandler) in
            
            let ExbitionToRemove = self.exhibitionList[indexPath.row]
            guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                else{
                    return
                    
            }
            print("Delete")
            let contextManager = appDelegate.persistentContainer.viewContext
            contextManager.delete(ExbitionToRemove)
            try! contextManager.save()
            // tried to remove geofencing monitoring two but did not worked.
            /* for exRegion in self.locationManager.monitoredRegions{
             guard let exRegion = exRegion as? CLCircularRegion, exRegion.identifier == self.exhibitionList[indexPath.row].name!
             else {
             continue
             }
             self.locationManager.stopMonitoring(for: exRegion)
             print("Geofencing Stopped!!!!")
             }*/
            
        }
        
        tableView.reloadData()
        return UISwipeActionsConfiguration(actions: [action])
       
        
    }
    
    // whenever we come to this page it will load.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
        tableView.reloadData()
        
        
    }
}
