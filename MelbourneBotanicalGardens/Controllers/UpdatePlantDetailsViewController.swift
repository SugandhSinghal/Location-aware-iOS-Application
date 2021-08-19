//
//  UpdatePlantDetailsViewController.swift
//  MelbourneBotanicalGardens
//  This class will update the plants detail.
//  Created by Sugandh Singhal on 10/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreData

// Using delegate protocol to pass the updated plant details from UpdatePlantDetailsViewController to PlantDetailViewController
protocol plantUpdate {
    func update(plant1: Plant)
}

class UpdatePlantDetailsViewController: UIViewController, UITextFieldDelegate {
    // Declaring some global variables
    var plant: Plant?
    var plantId: UUID? = nil
    
    // Declaring the delegate for which we have created the protocol above
    var delegate: plantUpdate?
    
    // Connecting all the text fields from storyboard to our controller.
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var sNameField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var fNameField: UITextField!
    
    // This view gets loaded as we come from PlantDetailViewController to UpdatePlantDetailsViewController
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Declaring delegates for text field. This will be used for dismissing our keyboard.
        nameField.delegate = self
        sNameField.delegate = self
        urlField.delegate = self
        yearField.delegate = self
        fNameField.delegate = self
        
        
        // Initially I am filling the already existing details to all the text field for the selected plant.
        guard let plant = plant
            else {
                return
                
        }
        nameField.text = plant.name
        sNameField.text = plant.scientificName
        urlField.text = plant.url
        yearField.text = plant.discoveryYear
        fNameField.text = plant.family
        
        
    }
    
    // This method is return to dismiss the keyboard on pressing return on the keyboard.
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // This method is return to dismiss the keyboard on pressing white space on screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    // This action will occure when someone presses the updateButton.
    @IBAction func updateButton(_ sender: Any) {
        
        // This is the final assignment of the valuse to the text field if user edit any value
        plant!.name = nameField.text
        plant!.scientificName = sNameField.text
        /* I could have given user option for image picking but I kept it simple here expecting user to
         put correct URL if he wants different image which is not very practical*/
        plant!.url = urlField.text
        plant!.discoveryYear = yearField.text
        plant!.family = fNameField.text
        // calling the delegate that I have created.
        delegate?.update(plant1: (self.plant)!)
        
        guard let plant = plant
            else {
                return
        }
        
        // One user has updated plant details I am updating the changed information to the core data.
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        let contextManager = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Plant")
        fetchRequest.predicate = NSPredicate(format: "%K == %@","id", plant.id! as CVarArg)
        
        do{
            let testing = try contextManager.fetch(fetchRequest)
            
            let updateObject = testing[0] as! NSManagedObject
            updateObject.setValue(nameField.text, forKey: "name")
            updateObject.setValue(sNameField.text, forKey: "scientificName")
            updateObject.setValue(urlField.text, forKey: "url")
            updateObject.setValue(yearField.text, forKey: "discoveryYear")
            updateObject.setValue(fNameField.text, forKey: "family")
            do{
                try contextManager.save()
            } catch {
                print("cannot save")
            }
        }catch{
            print("cannot update")
        }
        // After the update has been finished pop up to the previous view controller.
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
}

