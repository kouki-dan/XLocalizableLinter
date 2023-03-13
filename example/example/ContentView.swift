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
            Text("Hello, world?")
            Text(verbatim: NSLocalizedString("NSLocalizedString", comment: "This is from NSLocalizedString"))
            Text(
                "\"Keys may include double quote and equals(==) and backslash(\\)\"\"",
                comment: "Comments may include some character such as \", =, /*, //"
            )
            Text("interpolation: int \(1)")
            Text("interpolation: double \(1.0)")
            Text("interpolation: str \("1.0")")
            Text("interpolation: date \(Date())")
            Text("""
            multi
             "line"
              text
            """)
            SampleText("localizedStringKey")
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
