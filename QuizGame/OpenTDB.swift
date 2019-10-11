//
//  OpenTDB.swift
//  QuizzleTV
//
//  Created by Paul Wilkinson on 23/12/18.
//  Copyright © 2018 Paul Wilkinson. All rights reserved.
//

import Foundation
import GameFramework

public class OpenTDB { //}: GameProvider {
    
    private var categories:[OTDBCategory]?
    
    public init() {
        
    }
    
    public func getCategories(completion: @escaping ([GameCategory]?, Error?) -> Void) {
        
        if let categories = self.categories {
            completion(categories,nil)
            return
        }
        
        guard let url = URL(string: "https://opentdb.com/api_category.php") else {
            completion(nil,GameError("Unable to create url for categories"))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    completion(nil,error)
                    return }
            do{
                let decoder = JSONDecoder()
                let categories = try decoder.decode(OTDBCategories.self, from: dataResponse)
                self.categories = categories.categories.sorted { $0.name < $1.name }
                completion(self.categories,nil)
            } catch let parsingError {
                completion(nil,parsingError)
            }
        }
        task.resume()
        
    }

    public func getQuestions(for game: Game, completion: @escaping ([Question]?, Error?) -> Void) {
      
        var urlString = "https://opentdb.com/api.php?encode=base64&"
        urlString.append("amount=\(game.duration)")
        if let category = game.category {
            urlString.append("&category=\(category.id)")
        }
        
        if let difficultyLevel = game.difficulty {
            urlString.append("&difficulty=\(difficultyLevel.rawValue)")
        }
        
        guard let url = URL(string:urlString) else {
            completion(nil,GameError("Unable to create url for questions"))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    completion(nil,error)
                    return }
            do{
                let decoder = JSONDecoder()
                let questions = try decoder.decode(OTDBQuestions.self, from: dataResponse)
                completion(questions.questions,nil)
            } catch let parsingError {
                completion(nil,parsingError)
            }
        }
        task.resume()
    }
}

public struct OTDBCategories: Decodable {
    public var categories: [OTDBCategory]
    
    enum CodingKeys: String, CodingKey {
        case categories = "trivia_categories"
    }
}

public struct OTDBCategory: GameCategory, Decodable {
    public let id: Int
    public let name: String
}

public struct OTDBQuestions: Decodable {
    public let responseCode: Int
    public let questions: [OTDBQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case questions = "results"
    }
    
}

public struct OTDBQuestion: Question, Decodable {
    public let question: String
    public let category: String
    public let type: QuestionType
    public let difficulty: Difficulty
    public let answers: [String]
    public let correctAnswerIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case question = "question"
        case category = "category"
        case type = "type"
        case difficulty = "difficulty"
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let question = try values.decode(String.self, forKey: .question).base64Decoded(),
            let category = try values.decode(String.self, forKey: .category).base64Decoded(),
            let type = try values.decode(String.self, forKey: .type).base64Decoded(),
            let difficulty = try values.decode(String.self, forKey: .difficulty).base64Decoded(),
            let correctAnswer = try values.decode(String.self, forKey: .correctAnswer).base64Decoded() else {
                throw GameError("Cannot decode question")
        }
        var incorrectAnswersContainer = try values.nestedUnkeyedContainer(forKey: .incorrectAnswers)
        var incorrectAnswers = [String]()
        while !incorrectAnswersContainer.isAtEnd {
            if let answer = try incorrectAnswersContainer.decode(String.self).base64Decoded() {
                incorrectAnswers.append(answer)
            }
        }
        
        self.question = question
        self.category = category
        incorrectAnswers.append(correctAnswer)
        self.answers = incorrectAnswers.sorted()
        self.correctAnswerIndex = self.answers.firstIndex(of: correctAnswer)!
        
        if let questionType = QuestionType(rawValue: type) {
            self.type = questionType
        } else {
            throw GameError("Unknown question type \(type)")
        }
        
        if let questionDifficulty = Difficulty(rawValue: difficulty) {
            self.difficulty = questionDifficulty
        } else {
            throw GameError("Unknown diffculty  \(difficulty)")
        }
        
    }
}

