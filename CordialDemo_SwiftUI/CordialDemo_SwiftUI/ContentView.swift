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
    
    @EnvironmentObject var deepLinksPublisher: CordialSwiftUIDeepLinksPublisher
    
    var body: some View {
        if let deepLinkURL = self.deepLinkURL {
            DeepLinksView(url: deepLinkURL)
        } else {
            CatalogView()
                .onOpenURL(perform: { url in
                    CordialSwiftUIDeepLinksHandler().processDeepLink(url: url)
                })
                .onReceive(self.deepLinksPublisher.deepLinks) { deepLinks in
                    self.deepLinkURL = deepLinks.url
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
