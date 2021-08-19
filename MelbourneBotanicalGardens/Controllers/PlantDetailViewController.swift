//
//  PlantDetailViewController.swift
//  MelbourneBotanicalGardens
//  This controller will show the detail of selected plant.
//  Created by Sugandh Singhal on 10/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

// Here plantUpdate is the delegate comimg from UpdatePlantDetailsViewController will the updated plant information
class PlantDetailViewController: UIViewController, plantUpdate  {
    
    // Variable declaration which will store the information of the selected plant from ExhibitionSetailViewController
    var plant: Plant?
    // Connecting the labes from storyboard to the view controller
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var snameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var fnameLabel: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
    
    // This method is called when view loads for the first time.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting all the valuse to the labels to show plant detail.
        guard let plant = plant
            else {return}
        nameLabel.textColor = UIColor(named: "PlantLabel")
        self.nameLabel.text = plant.name
        self.snameLabel.text = plant.scientificName
        self.yearLabel.text = plant.discoveryYear
        self.fnameLabel.text = plant.family
        getPlantImage(imageString: plant.url!)
        
    }
    
    // Perform Segue to move to the UpdatePlantDetailsViewController and also transfering plant info.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updatePlantSegue"{
            let destination = segue.destination as! UpdatePlantDetailsViewController
            destination.plant  = plant
            destination.delegate = self
        }
    }
    
    @IBAction func updatePlant(_ sender: Any) {
        
    }
    
    
    // Using the delegate fuction to reload the updated information
    func update(plant1: Plant) {
        self.plant = plant1
        self.nameLabel.text = plant1.name
        self.snameLabel.text = plant1.scientificName
        self.yearLabel.text = plant1.discoveryYear
        self.fnameLabel.text = plant1.family
    }
    
    // This method is used for retriving the image from the API.
    func  getPlantImage(imageString: String){
        print("Download started")
        let imageURL = URL(string: imageString)
        print(imageString)
        let imageTask = URLSession.shared.dataTask(with: imageURL!) {(data, response, error) in
            if error != nil {
                self.plantImage.image = UIImage(named: "1")
                return
            }
            DispatchQueue.main.async {
                print("reached downloading.....")
                self.plantImage.image = UIImage(data: data!)
            }
        }
        imageTask.resume()
    }
    
}
