//
//  ContentView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 09.06.2021.
//

import SwiftUI
import CordialSDK 

struct ContentView: View {
    
    @State private var deepLinks: CordialSwiftUIDeepLinks?
    @State private var username = String()
    @State private var notificationSettings: String?
    
    @EnvironmentObject var appHandler: AppHandler
    
    @EnvironmentObject var pushNotificationPublisher: CordialSwiftUIPushNotificationPublisher
    @EnvironmentObject var pushNotificationCategoriesPublisher: CordialSwiftUIPushNotificationCategoriesPublisher
    @EnvironmentObject var deepLinksPublisher: CordialSwiftUIDeepLinksPublisher
    @EnvironmentObject var inboxMessagePublisher: CordialSwiftUIInboxMessagePublisher
    @EnvironmentObject var inAppMessagePublisher: CordialSwiftUIInAppMessagePublisher
    
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
            CatalogView(deepLinks: self.$deepLinks, notificationSettings: self.$notificationSettings)
                .onOpenURL { url in
                    CordialSwiftUIDeepLinksHandler().processDeepLink(url: url)
                }
                .onReceive(self.deepLinksPublisher.deepLinks) { deepLinks in
                    self.deepLinks = deepLinks
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
                .onReceive(self.pushNotificationCategoriesPublisher.openPushNotificationCategories, perform: { _ in
                    self.notificationSettings = "notificationSettings"
                })
                .onReceive(self.inboxMessagePublisher.newInboxMessageDelivered) { newInboxMessageDelivered in
                    print("SwiftUIApp: newInboxMessageDelivered, mcID: \(newInboxMessageDelivered.mcID)")
                }
                .onReceive(self.inAppMessagePublisher.inputsCaptured) { inputsCaptured in
                    print("SwiftUIApp: inputsCaptured, eventName: \(inputsCaptured.eventName), properties: \(inputsCaptured.properties.description)")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
