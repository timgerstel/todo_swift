//
//  TodoCellViewModel.swift
//  STodo
//
//  Created by Tim Gerstel on 5/4/21.
//

import Foundation
import Combine
import Resolver

class TodoCellViewModel: ObservableObject, Identifiable {
  @Injected var todoRepo: TodoRepo
  @Published var todo: Todo
  @Published var completeStateIconName = ""
  var id: String = ""
  
  private var cancellable = Set<AnyCancellable>()
  
  static func newTodo() -> TodoCellViewModel {
    TodoCellViewModel(todo: Todo(value: "", priority: .medium, complete: false))
  }
  
  init(todo: Todo){
    self.todo = todo;
    
    $todo
      .map { $0.complete ? "checkmark.circle.fill" : "circle" }
      .assign(to: \.completeStateIconName, on: self)
      .store(in: &cancellable)
    
    $todo
      .compactMap { $0.id }
      .assign(to: \.id, on: self)
      .store(in: &cancellable)
    
    $todo
      .dropFirst()
      .debounce(for: 0.8, scheduler: RunLoop.main)
      .sink { [weak self] todo in
        self?.todoRepo.updateTodo(todo)
      }
      .store(in: &cancellable)
  }
}
