//
//  AddPlantTableViewController.swift
//  MelbourneBotanicalGardens
//  This view controller is used to add plant to the new exhibition
//  Created by Sugandh Singhal on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreData

// Creating the delegate protocol to send the selected plant list from this controller to NewExhibitionViewController
protocol selectedPlantList {
    func listOfPlantSelected(plants: [Plant])
}

class AddPlantTableViewController: UITableViewController {
    
    // Declaring all the variables.
    var allPlant:[Plant] = []
    // Declaring the delegate
    var delegate: selectedPlantList?
    // used for storing selected plant.
    var plantSelected: [Plant] = []
    // used for storing images.
    var imageURLs: [String] = []
    var imagesUI: [UIImage] = []
    
    // This will load when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetching the plant list from the core data and storing it in allPlant
        createPlantList()
        // Allows user to select multiple rows as well as allow user to select during editing.
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelection = true
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allPlant.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plantCell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        let plant = allPlant[indexPath.row]
        plantCell.textLabel?.textColor = UIColor(named: "PlantLabel")
        plantCell.textLabel?.text = plant.scientificName
        plantCell.detailTextLabel?.text = plant.name
        
        if imagesUI.count == allPlant.count && imagesUI.count > 0 && indexPath.row <= imagesUI.count {
            
            plantCell.imageView?.image = imagesUI[indexPath.row]
            
        }
        else {
            plantCell.imageView?.image = UIImage(named: "3")
        }
        return plantCell
        
    }
    
    // Here selected plant will be stored.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = allPlant[indexPath.row]
        print(selected.name as Any)
        plantSelected.append(selected)
        print(plantSelected.count)
        
    }
    
    
    
    // This is used to deselect plant
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let notSelected = allPlant[indexPath.row]
        let plantName = notSelected.name
        plantSelected = plantSelected.filter({(plant) -> Bool in plant.name != plantName
        })
    }
    
    // This action occures when the button is pressed.
    // Reference: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
    @IBAction func selectPlantButton(_ sender: Any) {
        print(plantSelected.count)
        // If less than three plants are selected than an error message will come up
        if plantSelected.count < 3 {
            let alertMessage = UIAlertController(title: "Incorrect Selection", message: "Please select minimum 3 plants", preferredStyle:.alert)
            alertMessage.addAction(UIAlertAction(title: "OKAY", style: .default, handler: nil))
            self.present(alertMessage, animated: true)
        }
        // delegate to transfer the selected plant list to the NewExhibitionViewController
        delegate?.listOfPlantSelected(plants: self.plantSelected)
        // When button is pressed will take to previous screen.
        navigationController?.popViewController(animated: true)
        
    }
    
    // This is to fetch the data from the core data and store it in the plantList
    // Reference used for all core data operation: https://medium.com/@ankurvekariya/core-data-crud-with-swift-4-2-for-beginners-40efe4e7d1cc
    func createPlantList(){
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        _ = appDelegate.persistentContainer.viewContext
        let contextManager = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Plant>(entityName: "Plant")
        do{
            allPlant  = try contextManager.fetch(fetchRequest)
            //  self.storeImageAsync()
        }catch
        {
            print("Error in creating annotation object")
        }
    }
    
    // This method will always load whether you move from forward or backward.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
        self.imageURLsDownload()
        downloadImage()
        self.imagesUI.removeAll()
        tableView.reloadData()
        
    }
    
    // This method will store image url  which is String to the list for all plants
    func imageURLsDownload(){
        self.imageURLs.removeAll()
        for plant in allPlant
        {
            self.imageURLs.append(plant.url!)
        }
    }
    
    // This method will download the image and store in an list using API
    // User the lecture notes for week 6
    func downloadImage(){
        
        let imageURLString = imageURLs.removeFirst()
        let imageURL = URL(string: imageURLString)!
        let task = URLSession.shared.dataTask(with: imageURL){(data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                self.imagesUI.append(UIImage(data: data!)!)
                print("-----------------------")
                print(self.imagesUI.count)
                print("-----------------------")
                // I am facing issue with this as purple warning appears but I am anyways reloading data so that all images appear. 
                self.tableView.reloadData()
                
            }
            if self.imageURLs.count > 0{
                self.downloadImage()
            }else{
                // finished downloading
            }
            
        }
        task.resume()
        
    }
    
    
    
}
