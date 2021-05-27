//
//  TodoRepo.swift
//  STodo
//
//  Created by Tim Gerstel on 5/4/21.
//

import Foundation
import Disk
import FirebaseFirestore
import Combine
import Resolver

class BaseTodoRepo {
  @Published var todos = [Todo]()
}

protocol TodoRepo: BaseTodoRepo {
  func addTodo(_ todo: Todo)
  func removeTodo(_ todo: Todo)
  func updateTodo(_ todo: Todo)
}

class FirestoreTodoRepo: BaseTodoRepo, TodoRepo, ObservableObject {
  var db = Firestore.firestore()
  
  @Injected var authService: AuthService
  var todoPath: String = "todos"
  var userId: String = "anon"
  
  private var cancellable = Set<AnyCancellable>()
  
  override init(){
    super.init()
    authService.$user
      .compactMap { user in
        user?.uid
      }
      .assign(to: \.userId, on: self)
      .store(in: &cancellable)
    
    authService.$user
      .receive(on: DispatchQueue.main)
      .sink { [weak self] user in
        self?.loadData()
      }
      .store(in: &cancellable)
  }
  
  func addTodo(_ todo: Todo){
    do {
      var userTodo = todo
      userTodo.userId = self.userId
      let _ = try db.collection(todoPath).addDocument(from: userTodo)
    } catch {
      print("Error saving todo \(error.localizedDescription).")
    }
  }
  
  func removeTodo(_ todo: Todo){
    if let todoId = todo.id {
      db.collection(todoPath).document(todoId).delete { (error) in
        if let error = error {
          print("Error removing todo \(error.localizedDescription).")
        }
      }
    }
  }
  
  func updateTodo(_ todo: Todo){
    if let todoId = todo.id {
      do {
        try db.collection(todoPath).document(todoId).setData(from: todo)
      } catch {
        print("Error updating todo \(error.localizedDescription).")
      }
    }
  }
  
  private func loadData(){
    db.collection(todoPath)
      .whereField("userId", isEqualTo: self.userId)
      .order(by: "createdTime")
      .addSnapshotListener { (querySnapshot, error) in
      if let querySnapshot = querySnapshot {
        self.todos = querySnapshot.documents.compactMap { document -> Todo? in
          try? document.data(as: Todo.self)
        }
      }
    }
  }
}

class TestTodoRepo: BaseTodoRepo, TodoRepo, ObservableObject {
  override init(){
    super.init()
    loadTodos()
  }
  
  func addTodo(_ todo: Todo) {
    todos.append(todo)
    saveTodos()
  }
  
  func removeTodo(_ todo: Todo) {
    if let index = todos.firstIndex(where: {$0.id == todo.id}) {
      todos.remove(at: index)
      saveTodos()
    }
  }
  
  func updateTodo(_ todo: Todo) {
    if let index = self.todos.firstIndex(where: {$0.id == todo.id}) {
      self.todos[index] = todo;
      saveTodos()
    }
  }
  
  private func loadTodos() {
     if let retrievedTodos = try? Disk.retrieve("todos.json", from: .documents, as: [Todo].self) { // (1)
       self.todos = retrievedTodos
     }
   }
  
  private func saveTodos() {
     do {
      try Disk.save(self.todos, to: .documents, as: "todos.json") // (2)
     }
     catch let error as NSError {
       fatalError("""
         Domain: \(error.domain)
         Code: \(error.code)
         Description: \(error.localizedDescription)
         Failure Reason: \(error.localizedFailureReason ?? "")
         Suggestions: \(error.localizedRecoverySuggestion ?? "")
         """)
     }
   }
}
