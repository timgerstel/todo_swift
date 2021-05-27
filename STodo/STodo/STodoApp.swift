//
//  STodoApp.swift
//  STodo
//
//  Created by Tim Gerstel on 4/27/21.
//

import SwiftUI
import Resolver
import Firebase

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    // register application components
    register { FirestoreTodoRepo() as TodoRepo }.scope(.application)
    register { AuthService() }.scope(.application)
  }
}

@main
struct STodoApp: App {
  
  @Injected var authService: AuthService
  
  init() {
    FirebaseApp.configure()
    authService.signIn()
  }
  
  var body: some Scene {
    WindowGroup {
      TodoListView()
    }
  }
}
