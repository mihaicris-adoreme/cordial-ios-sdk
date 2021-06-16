//
//  ContentView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 09.06.2021.
//

import SwiftUI
import CordialSDK 

struct ContentView: View {
    
    @State private var deepLinkURL: URL?
    
    var body: some View {
        if let deepLinkURL = deepLinkURL {
            DeepLinksView(url: deepLinkURL)
        } else {
            CatalogView().onOpenURL(perform: { url in
                CordialDeepLinksAPI().openSwiftUIAppDeepLink(url: url, completionHandler: { url in
                    deepLinkURL = url
                })
            })
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
