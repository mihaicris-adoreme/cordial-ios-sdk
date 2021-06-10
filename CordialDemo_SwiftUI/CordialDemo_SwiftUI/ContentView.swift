//
//  ContentView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 09.06.2021.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
//        DeepLinksView(url: URL(string: "https://tjs.cordialdev.com/prep-tj1.html")!)
        CatalogView().onOpenURL(perform: { url in
            print(url.absoluteURL)
            DeepLinksView(url: url)
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
