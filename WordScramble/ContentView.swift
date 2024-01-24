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
    
    var body: some View {
        NavigationStack {
            List {
                Section{
                    TextField("Enter your Word", text: $newWord)
                    //disable captalization for this TextField
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id: \.self) { word in
                        //use Apple’s SF Symbols icons to show the length of each word next to the text. In this program we’ll be showing eight-letter words to users, so if they rearrange all those letters to make a new word the longest it will be is also eight letters. As a result, we can use those SF Symbols number circles just fine – we know that all possible word lengths are covered.
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            // call addNewWord method wen user press enter in the keyBoard. and in SwiftUI we can do that by adding an onSubmit() modifier somewhere in our view hierarchy – it could be directly on the button, but it can be anywhere else in the view because it will be triggered when any text is submitted.
            .onSubmit(addNewWord)
        }
    }
    
    //method to submit words from textField
    
    func addNewWord() {
        //lower case and trrim the word, to make sure we don't add dduplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit iif the remaining string is empty
        guard answer.count > 0 else { return }

        //anitating the insert procedure
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        
    }
    
}

#Preview {
    ContentView()
}
