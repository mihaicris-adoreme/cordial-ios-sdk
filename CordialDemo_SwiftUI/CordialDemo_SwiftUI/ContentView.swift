//
//  ContentView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 09.06.2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CatalogView()
            .onOpenURL(perform: { url in
                print(url)
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
