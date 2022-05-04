//
//  ProductView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 10.06.2021.
//

import SwiftUI

struct ProductView: View {
    
    var productID: Int
    
    var body: some View {
        Text("Product \(productID)")
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView(productID: 1)
    }
}
