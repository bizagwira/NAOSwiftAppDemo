//
//  ViewController.swift
//  NAOSwiftAppDemo
//
//  Created by Pole Star on 22/01/2020.
//  Copyright © 2020 Pole Star. All rights reserved.
//

import UIKit
import NAOSwiftProvider


class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var locationHandlerConsole: UITextView!
    @IBOutlet weak var apikey: UITextField!
    
    var readApikey: String!
    var locationProvider: LocationProvider?
    var geofencingHandler: GeofencingHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Configure the console
        self.locationHandlerConsole.text = "$ "
        self.locationHandlerConsole.isEditable = false
        self.locationHandlerConsole.delegate = self

        //Init didSynchronizationSuccess notification receiver
        NotificationCenter.default.addObserver(self, selector: #selector(didSynchronizationSuccess), name: NSNotification.Name("notifySynchronizationSuccess"), object: nil)
        
        //Init requiresCompassCalibration notification receiver
        NotificationCenter.default.addObserver(self, selector: #selector(requiresCompassCalibration), name: NSNotification.Name("notifyCompassCalibrationRequest"), object: nil)
        
        //Init requiresWifiOn notification receiver
        NotificationCenter.default.addObserver(self, selector: #selector(requiresWifiOn), name: NSNotification.Name("notifyWifiOnRequest"), object: nil)
        
        //Init requiresBLEOn notification receiver
        NotificationCenter.default.addObserver(self, selector: #selector(requiresBLEOn), name: NSNotification.Name("notifyBLEOnRequest"), object: nil)
        
        //Init requiresLocationOn notification receiver
        NotificationCenter.default.addObserver(self, selector: #selector(requiresLocationOn), name: NSNotification.Name("notifyLocationOnRequest"), object: nil)
        
        //Init didEnterSite notification receiver
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterSite), name: NSNotification.Name("notifyEnterSite"), object: nil)
        
        //Init didExitSite notification receiver
        NotificationCenter.default.addObserver(self, selector: #selector(didExitSite), name: NSNotification.Name("notifyExitSite"), object: nil)
        
        // Set OFF the location handle status
        switchButton.isOn =  UserDefaults.standard.bool(forKey: "switchState")
        

    }

    @IBAction func onApikeyValidButtonClicked(_ sender: UIButton) {
        // Read the apikey
        readApikey = apikey.text
        
        // Callbacks
        ServiceProvider.onErrorEventWithErrorCode = onLocationHandleFailure
        ServiceProvider.onSynchronizationFailure = onSynchronizationFailure
        
        // Init the location provider
        self.locationProvider = LocationProvider(apikey: readApikey)
        
        // Set the data and message callbacks
        self.locationProvider?.onLocationAvailable = onLocationAvailable
        self.locationProvider?.onLocationStatusChanged = onLocationStatusChanged
        
        // Init the geofencing handler
        self.geofencingHandler = GeofencingHandler(apikey: readApikey)
        // Set the data and message callbacks
        self.geofencingHandler?.onAlertEventWithMessage = onAlertEventWithMessage
    }
    
    @IBAction func locationSwitch(_ sender: UISwitch) {
        if (sender.isOn == true){
            self.locationProvider?.start()
            self.geofencingHandler?.start()
            self.locationHandlerConsole.text += "Location enabled\n$ "
        }
        else{
            self.locationProvider?.stop()
            self.geofencingHandler?.stop()
            self.locationHandlerConsole.text += "Location desabled\n$ "
        }
        
    }
    // MARK: - Data callbacks
      
      func onLocationAvailable (_ latitude: Float, _ longitude: Float, _ altitude: Int) -> (){
          self.locationHandlerConsole.text += "(\(latitude), \(longitude), \(altitude))\n$ "
      }
      
      
      func onSynchronizationFailure (_ message: String) -> (){
          self.locationHandlerConsole.text += "\(message)\n$ "
      }
      
      
      func onLocationHandleFailure (_ message: String) -> (){
          self.locationHandlerConsole.text += "\(message)\n$ "
      }
      
      
      func onLocationStatusChanged (_ message: String) -> (){
            self.locationHandlerConsole.text += "\(message)\n$ "
      }
      
      // MARK: - Notifications handler functions
      
      // Function that handles the synchronization notification
      @objc private func didSynchronizationSuccess() {
          self.locationHandlerConsole.text += "The synchronization is successful!\n$ "
      }
      
      // Function that handles the requiresCompassCalibration notification
      @objc private func requiresCompassCalibration() {
          self.locationHandlerConsole.text += "The campass calibration request!\n$ "
      }
      
      // Function that handles the requiresWifiOn notification
      @objc private func requiresWifiOn() {
          self.locationHandlerConsole.text += "The WiFi is ON!\n$ "
      }
      
      // Function that handles the requiresBLEOn notification
      @objc private func requiresBLEOn() {
          self.locationHandlerConsole.text += "The BLE is ON!\n$ "
      }
      
      // Function that handles the requiresLocationOn notification
      @objc private func requiresLocationOn() {
          self.locationHandlerConsole.text += "The location is ON!\n$ "
      }
      
      // Function that handles the didEnterSite notification
      @objc private func didEnterSite() {
          self.locationHandlerConsole.text += "Enters on the site!\n$ "
      }
      
      // Function that handles the didExitSite notification
      @objc private func didExitSite() {
          self.locationHandlerConsole.text += "Exits the site!\n$ "
      }
      
      // Function that handles the geofence alert messages
      @objc private func onAlertEventWithMessage(_ message: String) -> () {
          self.locationHandlerConsole.text += "\(message)!\n$ "
      }
}


extension ViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

