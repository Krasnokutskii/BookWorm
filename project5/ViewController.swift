//
//  ViewController.swift
//  project5
//
//  Created by Ярослав on 3/27/21.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        DispatchQueue.global().async {
            if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
                if let startWords = try? String(contentsOf: startWordsURL){
                    DispatchQueue.main.async { [weak self] in
                        self?.allWords = startWords.components(separatedBy: "\n")
                        self?.startGame()
                    }
                }
            }
        }
        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
        // Do any additional setup after loading the view.
        startGame()
    }

    @objc func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell 
    }

    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ string: String){
        let lowerAnsver = string.lowercased()
        
        if isPossible(lowerAnsver){
            if isOriginal(lowerAnsver){
                if isReal(lowerAnsver) && string.count > 3{
                    usedWords.insert(string, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                }else{
                    showErrorMassage(errorTitle: "The word not recognized", errorMassage: "wrong. word should contain more than 3 simbols")
                }
            }else{
                showErrorMassage(errorTitle: "Already used", errorMassage: "Be more original")
            }
        }else{
            guard let title = title else {
                return
            }
            showErrorMassage(errorTitle: "Word not possible", errorMassage: "you can't spell this word from \(title.lowercased())")
        }
        
    }
    
    func showErrorMassage(errorTitle: String, errorMassage: String){
        let ac = UIAlertController(title: errorTitle, message:errorMassage , preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(_ string: String)-> Bool{
        //delete characters of string one by one, and if char not exist return folse
        guard var tempString = title?.lowercased() else {
            return false
        }
        
        for letter in string{
            if let position = tempString.firstIndex(of: letter){
                tempString.remove(at: position)
            }else{
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(_ string: String)-> Bool{
        //if the word exist in the used words return false
        let tempString = string.lowercased()
        return !usedWords.contains(tempString)
    }
    
    func isReal(_ string: String)-> Bool{
        //if word is not real return false 
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: string.utf16.count)
        let misspeledRange = checker.rangeOfMisspelledWord(in: string, range: range, startingAt: 0, wrap: false, language: "en")
        
        if misspeledRange.location == NSNotFound{
            return true
        }else{
            return false
        }
    }
}

