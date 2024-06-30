//
//  HelpView.swift
//  Localife
//
//  Created by Abouzar Moradian on 6/25/24.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        List {
            Section(header: Text("Help & Support")) {
               // VStack(alignment: .leading, spacing: 8) {
                    Text("If you need assistance, please don't hesitate to reach out to us. We're here to help!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                    
                    HStack {
                        Text("Email: ")
                            .fontWeight(.bold)
                        Text("help.localife@gmail.com")
                            .foregroundColor(.blue)
                    }
               // }
               // .padding()
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Help & Support")
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
