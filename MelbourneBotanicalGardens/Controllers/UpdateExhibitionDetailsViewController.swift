//
//  UpdateExhibitionDetailsViewController.swift
//  MelbourneBotanicalGardens
//  This controller updates the exhibition detail
//  Created by Sugandh Singhal on 10/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreData

// Using delegate protocol to pass the updated exhibition details from UpdateExhibitionDetailsViewController to ExhibitionDetailViewController
protocol exhibitionUpdate {
    func update(exhibition : Exhibition)
}

class UpdateExhibitionDetailsViewController: UIViewController, UITextFieldDelegate {
    
    
    // Varible declaration
    // Information about the selected exhibition will come throught segue from ExhibitionDetailViewController and can be accessed by this variable.
    var exhibition: Exhibition?
    var exhibitionId: UUID? = nil
    // Declerating delegate
    var delegate: exhibitionUpdate?
    
    // connecting all the fields from storyboard to controller.
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var iconField: UITextField!
    
    // This is the screen that loads when we come to this page.
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let exhibition = exhibition
            else {
                return
                
        }
        
        // This will be used for the keyboard.
        nameField.delegate = self
        descriptionField.delegate = self
        latitudeField.delegate = self
        longitudeField.delegate = self
        iconField.delegate = self
        
        // Displaying the current information of the exhibition which user can update.
        nameField.text = exhibition.name
        descriptionField.text = exhibition.describe
        latitudeField.text = String(exhibition.lat)
        longitudeField.text = String(exhibition.long)
        iconField.text = exhibition.icon
        
        
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
    @IBAction func updateExhibitionButton(_ sender: Any) {
        // Inserting new values to the exhibition after user made changes.
        exhibition!.name = nameField.text
        exhibition!.describe = descriptionField.text
        if let text = latitudeField.text {
            let lat = Double(text)
            exhibition!.lat = lat!
        }
        if let text = longitudeField.text {
            let long = Double(text)
            exhibition!.long = long!
        }
        exhibition!.icon  = iconField.text
        
        // Sending the update information back to the view controller.
        delegate?.update(exhibition: (self.exhibition)!)
        
        // This method is used to update the exhibition in core data.
        guard let exhibition = exhibition
            else {return}
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        let contextManager = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Exhibition")
        fetchRequest.predicate = NSPredicate(format: "%K == %@","id", exhibition.id! as CVarArg)
        
        do{
            let testing = try contextManager.fetch(fetchRequest)
            
            let updateObject = testing[0] as! NSManagedObject
            updateObject.setValue(nameField.text, forKey: "name")
            updateObject.setValue(descriptionField.text, forKey: "describe")
            
            if let text = latitudeField.text {
                let lat = Double(text)
                //print(lat as Any)
                updateObject.setValue(lat, forKey: "lat")}
            
            if let text = longitudeField.text {
                let long = Double(text)
                // print(long as Any)
                updateObject.setValue(long, forKey: "lat")}
            updateObject.setValue(iconField.text, forKey: "icon")
            
            do{
                try contextManager.save()
            } catch {
                print("cannot save")
            }
        }catch{
            print("cannot update")
        }
        // Once the button is pressesd the previous screen pops up.
        navigationController?.popViewController(animated: true)
        
    }
    
}


