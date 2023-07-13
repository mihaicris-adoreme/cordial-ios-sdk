//
//  ProfileTableFooterView.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 11.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class ProfileTableFooterView: UITableViewHeaderFooterView {
    
    @IBAction func updateProfileAction(_ sender: UIButton) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let controller = App.getActiveViewController() {
            
            let attributes = AppDataManager.shared.attributes.getAttributesFromCoreData(appDelegate: appDelegate)
            CordialAPI().upsertContact(attributes: self.getAttributesDictionaryForCordialSDK(attributes: attributes))
            
            App.popupSimpleNoteAlert(title: "PROFILE", message: "UPDATED", controller: controller)
        }
    }
    
    private func getAttributesDictionaryForCordialSDK(attributes: [Attribute]) -> Dictionary<String, AttributeValue> {
        var attributesDictionary = Dictionary<String, AttributeValue>()
        
        attributes.forEach { attribute in
            let key = attribute.key
            
            switch attribute.type {
            case AttributeType.string:
                let value = Attribute.performArrayToStringSeparatedByComma(attribute.value)
                let stringValue = StringValue(value == "null" ? nil : value)
                attributesDictionary[key] = stringValue
            case AttributeType.boolean:
                let value = NSString(string:Attribute.performArrayToStringSeparatedByComma(attribute.value).lowercased()).boolValue
                let booleanValue = BooleanValue(value)
                attributesDictionary[key] = booleanValue
            case AttributeType.numeric:
                let value = Attribute.performArrayToStringSeparatedByComma(attribute.value)
                let numericValue = NumericValue(value == "null" ? nil : Double(value)!)
                attributesDictionary[key] = numericValue
            case AttributeType.array:
                let value = attribute.value
                let arrayValue = ArrayValue(Attribute.getArrayValue(value))
                attributesDictionary[key] = arrayValue
            case AttributeType.date:
                let value = Attribute.performArrayToStringSeparatedByComma(attribute.value)
                let dateValue = DateValue(value == "null" ? nil : CordialDateFormatter().getDateFromTimestamp(timestamp: value)!)
                attributesDictionary[key] = dateValue
            case AttributeType.geo:
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   let geoAttribute = AppDataManager.shared.geoAttributes.getGeoAttributeFromCoreDataByKey(appDelegate: appDelegate, key: key) {
                    
                    let city = geoAttribute.city
                    let country = geoAttribute.country
                    let postalCode = geoAttribute.postalCode
                    let state = geoAttribute.state
                    let streetAddress = geoAttribute.streetAddress
                    let streetAddress2 = geoAttribute.streetAddress2
                    let timeZone = geoAttribute.timeZone
                    
                    let geoValue = GeoValue()
                    
                    geoValue.setCity(city)
                    geoValue.setCountry(country)
                    geoValue.setPostalCode(postalCode)
                    geoValue.setState(state)
                    geoValue.setStreetAddress(streetAddress)
                    geoValue.setStreetAddress2(streetAddress2)
                    geoValue.setTimeZone(timeZone)
                    
                    attributesDictionary[key] = geoValue
                }
            }
        }
        
        return attributesDictionary
    }
}
