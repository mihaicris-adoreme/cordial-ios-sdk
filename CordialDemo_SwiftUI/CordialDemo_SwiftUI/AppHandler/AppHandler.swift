//
//  AppHandler.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 16.07.2021.
//

import Foundation

class AppHandler: ObservableObject {
    
    private init() {
        self.isUserLogin = UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
    }
    
    static let shared = AppHandler()
    
    @Published var isUserLogin = false
    
    private let USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN = "USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN"
    private let USER_DEFAULTS_KEY_FOR_USERNAME = "USER_DEFAULTS_KEY_FOR_USERNAME"
    
    func userLogIn(username: String) {
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
        UserDefaults.standard.set(username, forKey: USER_DEFAULTS_KEY_FOR_USERNAME)
        self.isUserLogin = true
    }
    
    func getUsername() -> String? {
        return UserDefaults.standard.string(forKey: USER_DEFAULTS_KEY_FOR_USERNAME)
    }
    
    func userLogOut() {
        UserDefaults.standard.set(false, forKey: USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEY_FOR_USERNAME)
        self.isUserLogin = false
    }
    
}
