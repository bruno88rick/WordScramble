//
//  ContentView.swift
//  WordScramble
//
//  Created by Bruno Oliveira on 22/01/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var wordScore = 0
    @State private var lettersScore = 0
    //properties to control alerts
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section{
                        TextField("Enter your Word", text: $newWord)
                        //disable captalization and autocorrection for this TextField
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                    
                    Section{
                        ForEach(usedWords, id: \.self) { word in
                            //use Apple’s SF Symbols icons to show the length of each word next to the text. In this program we’ll be showing eight-letter words to users, so if they rearrange all those letters to make a new word the longest it will be is also eight letters. As a result, we can use those SF Symbols number circles just fine – we know that all possible word lengths are covered.
                            HStack{
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            .accessibilityElement()
                            //.accessibilityLabel("\(word), \(word.count) letters") /// can do better:
                            .accessibilityLabel("\(word)")
                            .accessibilityHint("\(word.count) letters")
                        }
                    }
                }
            }
            //putting things near the safeArea (top or botton)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 20){
                    Text("Word Score:")
                        .font(.headline.bold())
                    Text("\(wordScore)")
                        .font(.title.bold())
                    Text("Letters Score:")
                        .font(.headline.bold())
                    Text("\(lettersScore)")
                        .font(.title2.bold())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
            }
            .navigationTitle(rootWord)
            // call addNewWord method when user press enter in the keyBoard. and in SwiftUI we can do that by adding an onSubmit() modifier somewhere in our view hierarchy – it could be directly on the button, but it can be anywhere else in the view because it will be triggered when any text is submitted.
            .onSubmit(addNewWord)
            // we need to actually call that StartGame func thing when our view is shown. SwiftUI gives us a dedicated view modifier for running a closure when a view is shown, so we can use that to call startGame() and get things moving – add this modifier after onSubmit():
            .onAppear(perform: startGame)
                // if we don't create a Button inside the alert, swift will present an OK Button anyway, so we can create an alert with empty button or without explicity a button, like this
            .alert(errorTitle, isPresented: $showingError) { } message: {
                    Text(errorMessage)
            }
            .toolbar {
                Button("New Word", action: startGame)
            }
        }
    }
    
    //method to submit words from textField
    
    func addNewWord() {
        //lower case and trrim the word, to make sure we don't add dduplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit iif the remaining string is empty
        guard answer.count > 0 else { return }
        
        // exit if the word is the same of root word
        guard answer != rootWord else {
            wordError(title: "Are you kidding  me, uh?", message: "Same word? I should close this! Try again!")
            return
        }
        
        guard answer.count > 3 else {
            wordError(title: "Too short!", message: "3 letters or less I cannot allow!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not Possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        //animating the insert procedure
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        calculateScores(word: answer)
        newWord = ""
    }
    
    //function to load on the start of the app
    
    func startGame () {
        // 1. Find the URL for start.txt in our app Bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //2. load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                //3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // if we are here everything has worked, so we can exit
                usedWords.removeAll()
                newWord = ""
                wordScore = 0
                lettersScore = 0
                return
            }
        }
        //if we are *here* then there was a problem - trigger a crash and report the error, using the method "fatalError".
        fatalError("Could not load start.txt from bundle.")
    }
    
    //verify if the word has been used or not
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    //func to verify if a random word can be made out of the leters from another random word. if we create a variable copy of the root word, we can then loop over each letter of the user’s input word to see if that letter exists in our copy. If it does, we remove it from the copy (so it can’t be used twice), then continue. If we make it to the end of the user’s word successfully then the word is good, otherwise there’s a mistake and we return false.
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    //So, our last method will make an instance of UITextChecker, which is responsible for scanning strings for misspelled words. We’ll then create an NSRange to scan the entire length of our string, then call rangeOfMisspelledWord() on our text checker so that it looks for wrong words. When that finishes we’ll get back another NSRange telling us where the misspelled word was found, but if the word was OK the location for that range will be the special value NSNotFound.
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError (title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func calculateScores(word: String)  {
        
        wordScore += 1
        lettersScore += word.count
        
    }
    
}

#Preview {
    ContentView()
}
