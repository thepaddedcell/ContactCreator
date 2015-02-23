//
//  ViewController.swift
//  ContactCreator
//
//  Created by Craig Stanford on 2/02/2015.
//  Copyright (c) 2015 MonsterBomb Pty Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func createContacts(sender: AnyObject) {
        if RHAddressBook.authorizationStatus().value == RHAuthorizationStatusNotDetermined.value {
            RHAddressBook().requestAuthorizationWithCompletion({ (granted, error) -> Void in
                if granted {
                    self.addContacts()
                }
            })
        } else if RHAddressBook.authorizationStatus().value == RHAuthorizationStatusDenied.value {
            let alert = UIAlertView(title: "Unable to access contacts", message: "Please go to your phone settings & allow us access to your contacts", delegate: self, cancelButtonTitle: "OK")
            //                if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
            switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
            case .OrderedSame, .OrderedDescending:
                alert.addButtonWithTitle("Settings")
            case .OrderedAscending:
                println("iOS < 8.0")
            }
            //
            //                }
            alert.show()
        } else {
            addContacts()
        }
    }

    func addContacts() {
        if let path = NSBundle.mainBundle().pathForResource("Names", ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                let addressBook = RHAddressBook()
                for nameObject in array {
                    if let name = nameObject as? String {
                        var person = addressBook.newPersonInDefaultSource()
                        let nameParts = name.componentsSeparatedByString(" ")
                        person.firstName = nameParts[0]
                        person.lastName = nameParts[1]
                        
                        let phoneMultiValue = person.phoneNumbers
                        var mutablePhoneMultiValue = phoneMultiValue.mutableCopy()
                        if (mutablePhoneMultiValue == nil) {
                            mutablePhoneMultiValue = RHMutableMultiStringValue(multiValueRef: kABMultiStringPropertyType)
                        }
                        let label = kABPersonPhoneIPhoneLabel as NSString
                        mutablePhoneMultiValue.addValue("+14086655555", withLabel:label)
                        person.phoneNumbers = mutablePhoneMultiValue
                        
                        let emailMultiValue = person.emails
                        var mutableEmailMultiValue = emailMultiValue.mutableCopy()
                        if (mutableEmailMultiValue == nil) {
                            mutableEmailMultiValue = RHMutableMultiStringValue(multiValueRef: kABMultiStringPropertyType)
                        }
                        let emailLabel = kABHomeLabel as NSString
                        mutableEmailMultiValue.addValue("\(nameParts[0])\(nameParts[1])@gmail.com", withLabel:emailLabel)
                        person.emails = mutableEmailMultiValue
                        
                        addressBook.addPerson(person)
                        println("Name: \(name)")
                    }
                }
                println("Saving...")
                addressBook.save()
                println("Saved!")
            }
        }
        UIAlertView(title: "Done!", message: "Like a dogs dinner", delegate: nil, cancelButtonTitle: "OK").show()
    }
}

