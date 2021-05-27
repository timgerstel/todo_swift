//
//  Todo.swift
//  STodo
//
//  Created by Tim Gerstel on 4/28/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum TodoAffinity: Int, Codable {
  case high
  case medium
  case low
}

struct Todo: Codable, Identifiable {
  @DocumentID var id: String?
  @ServerTimestamp var createdTime: Timestamp?
  var value: String
  var priority: TodoAffinity
  var complete: Bool
  var userId: String?
}

#if DEBUG
let testTodos = [
  Todo(value: "low", priority: .low, complete: false),
  Todo(value: "medium", priority: .medium, complete: false),
  Todo(value: "high", priority: .high, complete: false)
]
#endif
