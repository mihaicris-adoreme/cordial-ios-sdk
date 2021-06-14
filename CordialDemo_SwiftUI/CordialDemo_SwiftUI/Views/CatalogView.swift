//
//  CatalogView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 10.06.2021.
//

import SwiftUI

struct CatalogView: View {
    
    let title = "Catalog"
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: ProductView(productID: 1)) {
                        Text("\t\tProduct 1\t\t")
                            .navigationBarTitle(title, displayMode: .inline)
                    }
                    
                    Divider()
                    
                    NavigationLink(destination: ProductView(productID: 2)) {
                        HStack {
                            Text("\t\tProduct 2\t\t")
                                .navigationBarTitle(title, displayMode: .inline)
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    NavigationLink(destination: ProductView(productID: 3)) {
                        Text("\t\tProduct 3\t\t")
                            .navigationBarTitle(title, displayMode: .inline)
                    }
                    
                    Divider()
                    
                    NavigationLink(destination: ProductView(productID: 4)) {
                        Text("\t\tProduct 4\t\t")
                            .navigationBarTitle(title, displayMode: .inline)
                    }
                }
                
                Divider()
            }
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
    }
}
