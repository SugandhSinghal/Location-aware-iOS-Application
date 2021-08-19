//
//  NewExhibitionViewController.swift
//  MelbourneBotanicalGardens
//  This controller is used to store the new exhibition to the core data.
//  Created by Sugandh Singhal on 6/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

import CoreData
// Delegate is used to get the plant list from AddPlantTableViewController and for the keyboard disappear
class NewExhibitionViewController: UIViewController, selectedPlantList, UITextFieldDelegate {
    
    // Using the delegate fuction to get the plant list selected by the user
    func listOfPlantSelected(plants: [Plant]) {
        plantSelected = plants
    }
    
    // Declaring and Connecting the text field from storyboard to the controller
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var iconSegmentedControl: UISegmentedControl!
    
    // Declaring variables.
    var plantSelected: [Plant] = []
    var selectedImage: String = "5"
    
    // This view will load wjen we open this page.
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is done for keyboard to disappear
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
    }
    
    // Keyboard will disappear on pressing the return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Keyboard will disappear on clicking on white space.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // all the information that we asked user to enter is saved to the core data once the user clicks the button
    @IBAction func saveExhibition(_ sender: Any) {
        // applied form validation
        let validation = formValidation()
        
        if validation == true
        {
            selectedImage = iconSegmentedControl.titleForSegment(at: iconSegmentedControl.selectedSegmentIndex)!
            guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                else{
                    return
            }
            let contextManager = appDelegate.persistentContainer.viewContext
            let exhibitionEntity = NSEntityDescription.entity(forEntityName: "Exhibition", in: contextManager)
            let exhibitionAdd = NSManagedObject(entity: exhibitionEntity!, insertInto: contextManager)
            exhibitionAdd.setValue(nameTextField.text, forKey:"name")
            exhibitionAdd.setValue(descriptionTextField.text, forKey: "describe")
            exhibitionAdd.setValue(selectedImage, forKey: "icon")
            if let text = latitudeTextField.text {
                let lat = Double(text)
                exhibitionAdd.setValue(lat , forKey: "lat")}
            if let text = longitudeTextField.text {
                let long = Double(text)
                exhibitionAdd.setValue(long , forKey: "long")}
            exhibitionAdd.setValue(UUID(), forKey: "id")
            exhibitionAdd.setValue( NSSet.init(array: plantSelected), forKey: "plants")
            do{
                try contextManager.save()
                navigationController?.popViewController(animated: true)
            }catch let error as NSError{
                print("Could not save the Exhibition. \(error), \(error.userInfo)")
                popUpMessage()
                
            }
            
        }
        else {
            popUpMessage()
        }
    }
    
    
    
    // Reference : https://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
    // Form Validation
    func formValidation() -> Bool{
        var validation = true
        
        if nameTextField.text!.count < 1 {
            validation = false
            nameTextField.attributedPlaceholder = NSAttributedString(string: "Name Exhibition",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.green])
        }
        
        if descriptionTextField.text!.count < 1 {
            validation = false
            descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Description Exhibition",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.green])
        }
        
        
        if latitudeTextField.text!.count < 1 {
            validation = false
            latitudeTextField.attributedPlaceholder = NSAttributedString(string: "Latitude Exhibition",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.green])
        }
        
        
        if longitudeTextField.text!.count < 1 {
            validation = false
            longitudeTextField.attributedPlaceholder = NSAttributedString(string: "Latitude Exhibition",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.green])
        }
        
        if plantSelected.count == 0 {
            validation = false
            let alert = UIAlertController(title: "Plant Selection", message: "Plant not selected", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        return validation
    }
    
    // alert message for the save exhibition if the information is not valid.
    func popUpMessage (){
        let alertMessage = UIAlertController(title: "Add Exhibition", message: "Exhibition cannot be Added", preferredStyle: UIAlertController.Style.alert)
        alertMessage.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    // Perform Segue to go to AddPlantTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlantSegue"{
            let destination = segue.destination as! AddPlantTableViewController
            destination.delegate = self
        }
    }
    
    
}
