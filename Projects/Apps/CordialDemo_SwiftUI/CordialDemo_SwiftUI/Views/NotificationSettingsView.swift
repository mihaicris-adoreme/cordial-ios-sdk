//
//  NotificationSettingsView.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 13.03.2023.
//

import SwiftUI

struct NotificationSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Notification Settings")
                    .padding(.bottom, 100)
            }
        }.navigationTitle("App")
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
