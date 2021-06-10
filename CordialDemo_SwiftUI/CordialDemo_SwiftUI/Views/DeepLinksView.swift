//
//  DeepLinksView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 10.06.2021.
//

import Foundation
import UIKit
import SwiftUI

struct DeepLinksView: View {
    
    var url: URL
    
    var body: some View {
        if let productID = DeepLinks().getProductID(url: url) {
            ProductView(productID: productID)
        }
    }    
}
