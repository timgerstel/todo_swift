//
//  TodoListViewModel.swift
//  STodo
//
//  Created by Tim Gerstel on 5/4/21.
//

import Foundation
import Combine
import Resolver

class TodoListViewModel: ObservableObject {
  @Published var todoRepo: TodoRepo = Resolver.resolve()
  @Published var todoCellViewModels = [TodoCellViewModel]()
  private var cancellable = Set<AnyCancellable>()
  
  init() {
    todoRepo.$todos.map { todos in
      todos.map { todo in
        TodoCellViewModel(todo: todo)
      }
    }
    .assign(to: \.todoCellViewModels, on: self)
    .store(in: &cancellable)
  }
  
  func removeTodo(atOffsets indexSet: IndexSet) {
    let viewModels = indexSet.lazy.map { self.todoCellViewModels[$0] }
    viewModels.forEach { todoCellVM in
      todoRepo.removeTodo(todoCellVM.todo)
    }
  }
  
  func addTodo(todo: Todo){
    todoRepo.addTodo(todo)
  }
}
