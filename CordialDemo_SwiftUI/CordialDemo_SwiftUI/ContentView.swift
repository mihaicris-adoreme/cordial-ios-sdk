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
    @State private var username = String()
    
    @EnvironmentObject var deepLinksPublisher: CordialSwiftUIDeepLinksPublisher
    @EnvironmentObject var appHandler: AppHandler
    
    let cordialAPI = CordialAPI()
    
    var body: some View {
        if self.appHandler.isUserLogin {
            VStack {
                HStack {
                    if let username = self.appHandler.getUsername() {
                        Text(username)
                            .padding()
                    }
                    Spacer()
                    Button("Logout") {
                        self.appHandler.userLogOut()
                        self.cordialAPI.unsetContact()
                    }.padding()
                }
            }
        } else {
            VStack() {
                HStack {
                    TextField("Enter username...", text: self.$username)
                        .padding()
                    
                    if !self.username.isEmpty {
                        Button("Login") {
                            self.appHandler.userLogIn(username: self.username)
                            self.cordialAPI.setContact(primaryKey: self.username)
                            
                            self.cordialAPI.registerForPushNotifications(options: [.alert, .sound])
                        }.padding()
                    } else {
                        Button("Guest") {
                            self.appHandler.userLogIn(username: self.username)
                            self.cordialAPI.setContact(primaryKey: nil)
                            
                            self.cordialAPI.registerForPushNotifications(options: [.alert, .sound])
                        }.padding()
                    }
                }
            }
        }

        
        if self.appHandler.isUserLogin {
            CatalogView(deepLink: self.$deepLinkURL)
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
