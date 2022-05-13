//
//  AdvancedCreateView.swift
//  Bitkid
//
//  Created by Daniel Nordh on 5/6/22.
//

import SwiftUI

struct AdvancedCreateView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
            }
        }
        .navigationTitle("Advanced settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdvancedCreateView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedCreateView()
    }
}
