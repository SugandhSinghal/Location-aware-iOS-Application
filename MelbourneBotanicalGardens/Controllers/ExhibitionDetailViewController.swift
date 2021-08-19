//
//  ExhibitionDetailViewController.swift
//  MelbourneBotanicalGardens
//  This controller shows the exhibition detail.
//  Created by Sugandh Singhal on 8/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreData

// I have tried making
protocol annoationUpdate {
    func update(exhibition: Exhibition)
}

// Using two delegates here one coming from plant update and the other coing from exhibition update.
class ExhibitionDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,exhibitionUpdate , plantUpdate {
    
    // Using the delegate method to update the exhibition  information on the
    func update(exhibition: Exhibition) {
        self.nameLabel.text = exhibition.name
        self.descriptionLabel.text = exhibition.describe
        self.locationLabel.text = String(exhibition.lat)
        self.longLabel.text = String(exhibition.long)
        delegate?.update(exhibition: (self.exhibition)!)
        
    }
    // Using the delegate method to update the plant information on the ExhibitionDetailViewController
    func update(plant1: Plant) {
        plantselected = plant1
    }
    
    
    // variable declaration
    // information about the selected annoation comes through segue and stores here.
    var exhibitionSelected: ExhibitionAnnotation?
    var exhibition: Exhibition?
    var plantselected: Plant?
    var plantList: [Plant] = []
    // annotationUpdate delegtae declaration
    var delegate: annoationUpdate?
    
    // Connecting all the labels from storyboard to the controller
    @IBOutlet weak var plantListLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var plantTableView: UITableView!
    @IBOutlet weak var longLabel: UILabel!
    
    // The first function that run when view load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Featching the exhibition detail from core data for the selected annotation.
        loadExhibition()
        
        guard let exhibition = exhibition
            else {return}
        
        // Showing Exhibition details on screen
        self.nameLabel.text = exhibition.name
        self.descriptionLabel.text = exhibition.describe
        self.locationLabel.text = String(exhibition.lat)
        self.longLabel.text = String(exhibition.long)
        
        // using table view to show plants for the exhibition
        plantTableView.delegate = self
        plantTableView.dataSource = self
        
        // Adding some custom colours to the label
        nameLabel.textColor = UIColor(named: "ExhibitionLabel")
        plantListLabel.textColor = UIColor(named: "PlantLabel")
        
    }
    
    
    // Featching exhibition from core data and this function will be called in viewDidLoad
    func loadExhibition(){
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        let contextManager = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        do {
            let listExhibition  =  try contextManager.fetch(fetchRequest)
            for ExAnnotation in listExhibition{
                let id = ExAnnotation.id
                if id == exhibitionSelected?.id {
                    exhibition = ExAnnotation
                    plantList = exhibition?.plants?.allObjects as! [Plant]
                    //  print(plantList[0].name ?? "plants--" )
                    
                }
                
            } } catch{
                print("Cannot fetch Exhibition")
        }
        
    }
    
    // Code for table that we have inserted for the plant list in the exhibition
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  plantList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for:indexPath)
        let plant = plantList[indexPath.row].name
        cell.textLabel?.text = plant
        return cell
    }
    
    // Storing the information of selected plant from the list in plantselected variable which can be transfer to plant detail view controler through segue.
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        
        plantselected = plantList[indexPath.row]
        performSegue(withIdentifier: "detailPlantSegue", sender: self)
    }
    
    
    
    // Perform Segue for moving to the detail plant screen and transfering the information of selected plant.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPlantSegue"{
            let destination = segue.destination as! PlantDetailViewController
            destination.plant  = plantselected
            
            
        }
        // Perform Segue for moving to the exhibition update screen and transfering exhibition information
        if segue.identifier == "updateExhibitionSegue"{
            let destination = segue.destination as! UpdateExhibitionDetailsViewController
            destination.exhibition  = exhibition
            destination.delegate = self
        }
    }
    
    
    // viewWillAppear method is always called when ever we move to that screen forward or backward so we are loading all the infortaion to update .
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
        plantTableView.reloadData()
    }
    
    
}
