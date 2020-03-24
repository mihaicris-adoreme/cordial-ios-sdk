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
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let controller = getActiveViewController() {
            let attributes = AppDataManager.shared.attributes.getAttributesFromCoreData(appDelegate: appDelegate)
            CordialAPI().upsertContact(attributes: self.modifyAttributesData(attributes: attributes))
            
            popupSimpleNoteAlert(title: "PROFILE", message: "UPDATED", controller: controller)
        }
    }
    
    private func modifyAttributesData(attributes: [Attribute]) -> Dictionary<String, AttributeValue> {
        var attributesDictionary = Dictionary<String, AttributeValue>()
        
        attributes.forEach { attribute in
            let key = attribute.key
            
            switch attribute.type {
            case AttributeType.string:
                let value = Attribute.performArrayToStringSeparatedByComma(attribute.value)
                let stringValue = StringValue(value)
                attributesDictionary[key] = stringValue
            case AttributeType.boolean:
                let value = NSString(string:Attribute.performArrayToStringSeparatedByComma(attribute.value).lowercased()).boolValue
                let booleanValue = BooleanValue(value)
                attributesDictionary[key] = booleanValue
            case AttributeType.numeric:
                let value = Double(Attribute.performArrayToStringSeparatedByComma(attribute.value))!
                let numericValue = NumericValue(value)
                attributesDictionary[key] = numericValue
            case AttributeType.array:
                let value = attribute.value
                let arrayValue = ArrayValue(value)
                attributesDictionary[key] = arrayValue
            case AttributeType.date:
                let value = CordialDateFormatter().getDateFromTimestamp(timestamp: Attribute.performArrayToStringSeparatedByComma(attribute.value))!
                let dateValue = DateValue(value)
                attributesDictionary[key] = dateValue
            case AttributeType.geo:
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let geoAttribute = AppDataManager.shared.geoAttributes.getGeoAttributeFromCoreDataByKey(appDelegate: appDelegate, key: key) {
                    
                    let city = geoAttribute.city
                    let country = geoAttribute.country
                    let postalCode = geoAttribute.postalCode
                    let state = geoAttribute.state
                    let streetAdress = geoAttribute.streetAdress
                    let streetAdress2 = geoAttribute.streetAdress2
                    let timeZone = geoAttribute.timeZone
                    
                    let geoValue = GeoValue(key: key)
                    
                    geoValue.setCity(city)
                    geoValue.setCountry(country)
                    geoValue.setPostalCode(postalCode)
                    geoValue.setState(state)
                    geoValue.setStreetAdress(streetAdress)
                    geoValue.setStreetAdress2(streetAdress2)
                    geoValue.setTimeZone(timeZone)
                    
                    attributesDictionary[key] = geoValue
                }
            }
        }
        
        return attributesDictionary
    }
}
