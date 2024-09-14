//
//  DaysOffView.swift
//  DaysOff
//
//  Created by Tony Short on 14/09/2024.
//

import SwiftUI
import SwiftData

struct DaysOffView: View {
    var body: some View {
        NavigationStack {
            Text("Days Left: 26 days")
                .navigationTitle("Days Off in 2024")
        }
    }
}

#Preview {
    DaysOffView()
}
