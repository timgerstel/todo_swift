//
//  TodoListView.swift
//  STodo
//
//  Created by Tim Gerstel on 4/28/21.
//

import SwiftUI

struct TodoListView: View {
  @ObservedObject var todoListVM = TodoListViewModel()
  @State var showNewTodo = false;
  var todoList: [Todo] = testTodos
  
  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        List {
          ForEach(todoListVM.todoCellViewModels) { todoCellVM in
            TodoCell(todoCellViewModel: todoCellVM)
          }.onDelete { indexSet in
            self.todoListVM.removeTodo(atOffsets: indexSet)
          }
          if showNewTodo {
            TodoCell(todoCellViewModel: TodoCellViewModel.newTodo()) { result in
              if case .success(let todo) = result {
                self.todoListVM.addTodo(todo: todo)
              }
              self.showNewTodo.toggle()
            }
          }
        }
        Button(action: { self.showNewTodo.toggle() }) {
          HStack {
            Image(systemName: "plus.circle.fill")
              .resizable()
              .frame(width: 20, height: 20)
            Text("New")
          }
        }
        .padding()
        .accentColor(Color(UIColor.systemRed))
      }
      .navigationBarTitle("TGTodo")
    }
  }
}

enum InputError: Error {
  case empty
}

//struct TodoListView_Previews: PreviewProvider {
//  static var previews: some View {
//    TodoListView()
//  }
//}

struct TodoCell: View {
  @ObservedObject var todoCellViewModel: TodoCellViewModel
  var onCommit: (Result<Todo, InputError>) -> Void = { _ in }
  
  var body: some View {
    HStack {
      Image(systemName: todoCellViewModel.completeStateIconName)
        .resizable()
        .frame(width: 20, height: 20)
        .onTapGesture {
          self.todoCellViewModel.todo.complete.toggle()
        }
      TextField("Enter new task", text: $todoCellViewModel.todo.value,
        onCommit: {
          if !self.todoCellViewModel.todo.value.isEmpty {
            self.onCommit(.success(self.todoCellViewModel.todo))
          } else {
            self.onCommit(.failure(.empty))
          }
        }).id(todoCellViewModel.id)
    }
  }
}
