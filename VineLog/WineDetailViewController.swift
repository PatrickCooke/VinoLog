//
//  WineDetailViewController.swift
//  VineLog
//
//  Created by Patrick Cooke on 5/19/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import AVFoundation

class WineDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let backendless = Backendless.sharedInstance()
    var currentuser = BackendlessUser()
    var loginManager = LoginManager.sharedInstance
    var newWine = WineEntry?()
    
    @IBOutlet private weak var wineNameField        :UITextField!
    @IBOutlet private weak var wineVintageField     :UITextField!
    @IBOutlet private weak var wineVarietalField    :UITextField!
    @IBOutlet private weak var wineWineryField      :UITextField!
    @IBOutlet private weak var wineCategoryField    :UITextField!
    @IBOutlet private weak var wineConsumedPicker   :UIDatePicker!
    @IBOutlet private weak var wineImageView        :UIImageView!
    @IBOutlet private weak var wineRatingSegCtrlr   :UISegmentedControl!
    @IBOutlet private weak var capturedImage: UIImageView!
    
    //MARK: - Save File Methods
    
    @IBAction private func saveButtonPressed(button: UIButton) {
        if let image = capturedImage.image {
            let imagePath = getDocumentForPathForFile(getNewImageFileName())
            UIImagePNGRepresentation(image)!.writeToFile(imagePath, atomically: true)
        } else {
            print("no image to save")
        }
    }
    
    func getNewImageFileName() -> String {
        return NSProcessInfo.processInfo().globallyUniqueString + ".png"
    }
    
    func getDocumentForPathForFile(filename :String) -> String {
        let docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask , true)[0] as NSString
        print("Path; \(docPath)")
        return docPath.stringByAppendingPathComponent(filename)
    }
    
    //MARK: - Build-In Camera Methods
    
    @IBAction private func galleryButtonTapped(button: UIBarButtonItem) {
        print("gallery")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .SavedPhotosAlbum //aka the camera roll
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction private func cameraButtonTapped(button: UIBarButtonItem) {
        print("Camera")
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }else{
            print("No Camera")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        capturedImage.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    //MARK: - Save stuff
    
    @IBAction private func saveWine(button: UIBarButtonItem) {
        guard let name = wineNameField.text else {
            return}
        let newWine = WineEntry()
        newWine.wineName = name
        newWine.wineVintage = wineVintageField.text
        newWine.wineVarietal = wineVarietalField.text
        newWine.wineWinery = wineWineryField.text
        newWine.wineCategory = wineCategoryField.text
        newWine.consummedDate = wineConsumedPicker.date
        newWine.wineRating = wineRatingSegCtrlr.selectedSegmentIndex
        //newWine.winePhotoName = wineImageView.image
        
        
        let dataStore = backendless.data.of(newWine.ofClass())
        dataStore.save(newWine, response: { (result) in
            print("Req Saved")
        }) { (fault) in
            print("server reported error: \(fault)")
        }
        
        self.navigationController!.popViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "wineSaved", object: nil))
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if newWine?.objectId == nil{
            wineNameField.text = ""
            wineVintageField.text = ""
            wineVarietalField.text = ""
            wineWineryField.text = ""
            wineCategoryField.text = ""
            wineConsumedPicker.date = NSDate()
            wineImageView.image = nil
            wineRatingSegCtrlr.selectedSegmentIndex = 1
        } else {
            wineNameField.text = newWine!.wineName
            wineVintageField.text = newWine!.wineVintage
            wineVarietalField.text = newWine!.wineVarietal
            wineWineryField.text = newWine!.wineWinery
            wineCategoryField.text = newWine!.wineCategory
            wineConsumedPicker.date = newWine!.consummedDate
            wineImageView.image = nil
            wineRatingSegCtrlr.selectedSegmentIndex = newWine!.wineRating
        }
 }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
