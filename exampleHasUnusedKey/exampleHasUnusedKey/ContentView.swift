//
//  ContentView.swift
//  example
//
//  Created by Kouki Saito on 2023/03/09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            // replace `!` for `?`
            Text("Hello, world?")
            // add `!`
            Text(verbatim: NSLocalizedString("NSLocalizedString!", comment: "This is from NSLocalizedString"))
            // No changes
            Text(
                "\"Keys may include double quote and equals(==) and backslash(\\)\"\"",
                comment: "Comments may include some character such as \", =, /*, //"
            )
            // Capitalize
            Text("Interpolation: int \(1)")
            Text("Interpolation: double \(1.0)")
            Text("Interpolation: str \("1.0")")
            Text("Interpolation: date \(Date())")
            // remove double quote
            Text("""
            multi
             line
              text
            """)
            // remove string
            // SampleText("localizedStringKey")
        }
        .padding()
    }
}

struct SampleText: View {
    var text: LocalizedStringKey

    init(_ text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        Text(text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
