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
    
    @EnvironmentObject var appHandler: AppHandler
    
    @EnvironmentObject var pushNotificationPublisher: CordialSwiftUIPushNotificationPublisher
    @EnvironmentObject var deepLinksPublisher: CordialSwiftUIDeepLinksPublisher
    @EnvironmentObject var inboxMessagePublisher: CordialSwiftUIInboxMessagePublisher
    
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
                .onOpenURL { url in
                    CordialSwiftUIDeepLinksHandler().processDeepLink(url: url)
                }
                .onReceive(self.deepLinksPublisher.deepLinks) { deepLinks in
                    self.deepLinkURL = deepLinks.url
                }
                .onReceive(self.pushNotificationPublisher.appOpenViaNotificationTap) { appOpenViaNotificationTap in
                    print("SwiftUIApp: appOpenViaNotificationTap, notificationContent: \(appOpenViaNotificationTap.notificationContent)")
                }
                .onReceive(self.pushNotificationPublisher.notificationDeliveredInForeground) { notificationDeliveredInForeground in
                    print("SwiftUIApp: notificationDeliveredInForeground, notificationContent: \(notificationDeliveredInForeground.notificationContent)")
                }
                .onReceive(self.pushNotificationPublisher.apnsTokenReceived) { apnsTokenReceived in
                    print("SwiftUIApp: apnsTokenReceived, token: \(apnsTokenReceived.token)")
                }
                .onReceive(self.inboxMessagePublisher.newInboxMessageDelivered) { newInboxMessageDelivered in
                    print("SwiftUIApp: newInboxMessageDelivered, mcID: \(newInboxMessageDelivered.mcID)")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
