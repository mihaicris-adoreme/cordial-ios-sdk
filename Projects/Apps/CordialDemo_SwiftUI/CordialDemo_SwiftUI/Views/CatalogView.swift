//
//  CatalogView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 10.06.2021.
//

import SwiftUI
import CordialSDK

struct CatalogView: View {
    
    let title = "Catalog"
    
    @Binding var deepLinks: CordialSwiftUIDeepLinks?
    
    @State var productID: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                
                if let deepLinks = self.deepLinks, let productID = DeepLinks(deepLinks: deepLinks).getProductID() {
                    NavigationLink(destination: ProductView(productID: productID), tag: productID, selection: self.$productID) {
                        EmptyView()
                    }
                    .onAppear {
                        self.productID = productID
                    }
                }
                
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
    
    @State static private var deepLinks: CordialSwiftUIDeepLinks?
    
    static var previews: some View {
        CatalogView(deepLinks: self.$deepLinks)
    }
}
