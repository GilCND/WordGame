//
//  ViewController.swift
//  WordGame
//
//  Created by Felipe Gil on 2021-06-07.
//

import UIKit

class ViewController: UITableViewController {
    var allWords: [String] = []
    var usedWords: [String] = []
    let defaults = UserDefaults.standard
    let wordTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loadLastGames = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(loadLastGame))
        let restartGame = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItems = [loadLastGames, restartGame]
        navigationController?.isToolbarHidden = false
        
        
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["fileError"]
        }
        loadLastGame()
    }
    
    @objc private func startGame() {
        saveData()
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    @objc private func loadLastGame() {
        loadData()
        tableView.reloadData()
     }
    private func saveData() {
        defaults.set(title, forKey: "title")
        defaults.set(usedWords, forKey: "allWords")
    }
    private func loadData() {
        title = defaults.string(forKey: "title")
        usedWords = defaults.array(forKey: "allWords") as? [String] ?? [String]()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc private func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAction = UIAlertAction(title: "submit", style: .default) {
            [weak self, weak alertController] action in
            guard let answer = alertController?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    private func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    if isValid(word: lowerAnswer) {
                        usedWords.insert(lowerAnswer, at: 0)
                        let indexPath = IndexPath (row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        return
                    }
                } else {
                    showErrorMessage(errorCode: 3)
                }
            } else {
                showErrorMessage(errorCode: 2)
            }
        } else {
            showErrorMessage(errorCode: 1)
        }
    }
    
    private func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position) } else { return false }
            }
        return true
    }
    
    private func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        if misspelledRange.location == NSNotFound {
            return true
        } else {
            return false
        }
    }
    
    private func isValid(word: String) -> Bool {
        if word.count > 2 {
            return true
        } else {
            return false
        }
    }
    
    private func showErrorMessage(errorCode: Int) {
        var errorTitle: String = ""
        var errorMessage: String = ""
        
        if errorCode == 3 {
            errorTitle = "Word not recognized"
            errorMessage = "You can't just make the words up"
        }
        if errorCode == 2 {
            errorTitle = "Word already used"
            errorMessage = "Try again"
        }
        if errorCode == 1 {
            guard let title = title else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title.lowercased())."
        }
         
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

