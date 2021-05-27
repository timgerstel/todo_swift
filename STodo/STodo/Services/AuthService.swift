//
//  AuthService.swift
//  STodo
//
//  Created by Tim Gerstel on 5/22/21.
//

import Foundation
import Firebase

class AuthService: ObservableObject {
  
  @Published var user: User?
  
  func signIn(){
    registerStateListener()
    Auth.auth().signInAnonymously()
  }
  
  private func registerStateListener(){
    Auth.auth().addStateDidChangeListener{ (auth, user) in
      self.user = user
      if let user = user {
        let anon = user.isAnonymous ? "anonymously" : ""
        print("User signed in \(anon) with user ID \(user.uid)")
      } else {
        print("User signed out.")
      }
    }
  }
}
