//
//  usernameViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/22/24.
//

import Foundation

enum UsernameValidationError: String {
    case tooShort = "Username must be at least 4 characters long"
    case tooLong = "Username must be no more than 20 characters long"
    case invalidCharacters = "Username can only contain alphanumeric characters, dashes, and underscores"
    case valid = " "
    case notAvailable = "This username is already taken by another user"
    case empty = "Please enter a username to continue"
    case initial = ""
}


@MainActor
final class UsernameViewModel: ObservableObject {
     
    @Published var username: String = ""
    @Published var validity: UsernameValidationError = .initial
    let maximumLength = 20
    let minimumLenght = 4
    @Published var done: Bool = false
  

    var user: DBUser
    
    init(user: DBUser){
        self.user = user
        Task{
            try await setInitialUsername()
        }
    }
    
    
    
    func generateRandomUsername(high: Int) -> String {
        let letters = "0123456789"
        let length = Int.random(in: 2...high)
        
        
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    
    func fetchRandomWords(count: Int) async throws -> [String] {
        let urlString = "https://random-word-api.herokuapp.com/word?number=\(count)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let words = try JSONDecoder().decode([String].self, from: data)
        return words
    }
    
    func setRandomUsername() async throws{
        
        var isAvailable = false
        do {
            while !isAvailable{
                
                let words = try await fetchRandomWords(count: 1)
                let randomUsername = words.joined(separator: ", ")
                let validity = validateUsername(randomUsername)
                if validity != .valid { continue}
                isAvailable = try await isUsernameAvailable(username: randomUsername )
                if isAvailable {username = randomUsername}
                
            }
        } catch {
            print("Failed to fetch words: \(error)")
        }
            
    }
    
    
    func makeUniqueUsername(initialUsername: String) async throws{
        
        var newUsername =  initialUsername.lowercased()
        var isAvailable = false
        do {
            isAvailable = try await isUsernameAvailable(username: newUsername )
            while !isAvailable{
                let validity = validateUsername(newUsername)
                if validity != .valid {
                    let words = try await fetchRandomWords(count: 1)
                    newUsername = words.joined(separator: ", ")
                }
                isAvailable = try await isUsernameAvailable(username: newUsername)
                if isAvailable {
                    self.username = newUsername
                }else{
                   let high = min(abs(maximumLength - newUsername.count), minimumLenght + 1)
                   let randomNumber = generateRandomUsername(high: high)
                   newUsername = ("\(newUsername)\(randomNumber)")
                }
                
                
            }
            
            self.username = newUsername
        } catch {
            print("Failed to fetch words: \(error)")
        }
        
        
            
    }
    
    func isUsernameAvailable(username: String) async throws -> Bool{
        return try await UserManager.shared.checkUsernameAvailability(userId: user.id, username: username)
    }
    
    func setInitialUsername() async throws {
        var newUsername = ""
        if let firstName = user.firstName, firstName.count <= maximumLength{
            newUsername = firstName
        }
        if let lastName = user.lastName, lastName.count <= maximumLength{
            let fullName = "\(newUsername)\(lastName)"
            if fullName.count <= maximumLength{
                newUsername = fullName
            }
        }
        
        if newUsername != ""{
            do{
                try await makeUniqueUsername(initialUsername: newUsername)
                try await saveUsername()
            }
            
        }else{
            do{
                try await setRandomUsername()
                try await saveUsername()
            }
            
        }
    }
    
    func saveUsername() async throws {
        do{
            try await UserManager.shared.updateUsername(userId: user.id, username: username)
            
        }
    }
    
    func setEnteredUsername() async throws {
        do{
            validity = validateUsername(username)
            if validity == .valid{
                
                let isAvailable = try await  isUsernameAvailable(username: username)
                if !isAvailable {
                    validity = .notAvailable
                    return
                }
                
                try await saveUsername()
                done = true
                print("Done >>>>>>>>>>>>>")
            } else {
                return
            }
        }
        
    }
    
    
    func validateUsername(_ username: String) -> UsernameValidationError {
        // Check if the username is between 4 and 20 characters long
        if username.count < 4 {
            return .tooShort
        }
        
        if username.count > 20 {
            return .tooLong
        }
        
        // Regular expression to check for allowed characters (alphanumeric, dashes, and underscores)
        let regex = "^[a-zA-Z0-9_-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if !predicate.evaluate(with: username) {
            return .invalidCharacters
        }
        
        return .valid
    }
    
    

}
