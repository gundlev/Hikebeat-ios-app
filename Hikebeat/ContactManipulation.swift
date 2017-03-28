//
//  ContactManipulation.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 23/02/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import ContactsUI
import BrightFutures

func createHikebeatContact() -> Future<Bool, HikebeatError>  {
    return Future { complete in
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            print("should check for hikebeat contact")
            if !hikbeatContactExist(store: store) {
                addHikebeatContact(store: store)
                .onSuccess(callback: { (success) in
                    complete(.success(success))
                }).onFailure(callback: { (error) in
                    print("Error: ", error)
                    complete(.failure(.createContact))
                })
            } else {
                complete(.success(false))
            }
        //TODO: check if hikebeat contact is created.
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else {
                    complete(.failure(.createContact))
                    return
                }
                addHikebeatContact(store: store)
                .onSuccess(callback: { (success) in
                    complete(.success(success))
                }).onFailure(callback: { (error) in
                    print("Error: ", error)
                    complete(.failure(.createContact))
                })
            }
        case .denied:
            UIApplication.openAppSettings()
            complete(.failure(.createContact))
        default:
            complete(.success(false))
            print("Haven't got permission to access contacts")
        }
    }
}

func hikbeatContactExist(store: CNContactStore) -> Bool {
    let predicate = CNContact.predicateForContacts(matchingName: "Hikebeat")
    let keys = [CNContactGivenNameKey]
    var contacts = [CNContact]()
    do {
        contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
        if contacts.count == 0 {
            return false
        } else {
            return true
        }
    }
    catch {
        return false
    }
}

func addHikebeatContact(store: CNContactStore) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let contactData = CNMutableContact()
        contactData.givenName = "Hikebeat"
        contactData.organizationName = "Hikebeat"
        let img = UIImage(named: "ContactImage")
        let phoneNumber = userDefaults.string(forKey: "hikebeat_phoneNumber")!
        contactData.imageData = UIImagePNGRepresentation(img!)
        contactData.phoneNumbers = [CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: phoneNumber))]
        contactData.emailAddresses = [CNLabeledValue(label: CNLabelWork,value: "contact@hikebeat.com")]
        let facebookProfile = CNLabeledValue(label: "FaceBook", value:
            CNSocialProfile(urlString: nil, username: "Hikebeat",
                            userIdentifier: nil, service: CNSocialProfileServiceFacebook))
        contactData.socialProfiles = [facebookProfile]
        
        let request = CNSaveRequest()
        request.add(contactData, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            complete(.success(true))
            print("Successfully added the contact")
        } catch let err{
            complete(.failure(.createContact))
            print("Failed to save the contact. \(err)")
        }
    }
}
