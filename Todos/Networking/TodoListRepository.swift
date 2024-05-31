import UIKit

class TodoListRepository {
    
    typealias TodoListResponse = [String: TodoListDTO]
    
    private let todosURL = URL(string: "https://todos-16ed9-default-rtdb.europe-west1.firebasedatabase.app/todos.json")!
    
    func fetchTodoLists() async throws -> [TodoList] {
        
        let request = URLRequest(url: todosURL)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(TodoListResponse.self, from: data)
        
        return toDomain(decoded)
    }
    
    func addTodoList(_ todoList: TodoList) async throws -> String {
        var request = URLRequest(url: todosURL)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(todoList.toData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(AddTodoListResponse.self, from: data)
        
        return decoded.name
    }
    
    private func toDomain(_ todoListRespopnse: TodoListResponse) -> [TodoList] {
        var result = [TodoList]()
        
        for (_, todoListDTO) in todoListRespopnse {
            result.append(todoListDTO.toDomain)
        }
        
        return result
    }
}

extension TodoListDTO {
    var toDomain: TodoList {
        TodoList(
            title: self.title,
            image: icon,
            color: UIColor(hex: color) ?? .clear,
            items: items
        )
    }
}

extension TodoList {
    var toData: TodoListDTO {
        TodoListDTO(
            color: color.hexString ?? "#FFFFFF",
            icon: image,
            title: title,
            items: items
        )
    }
}
