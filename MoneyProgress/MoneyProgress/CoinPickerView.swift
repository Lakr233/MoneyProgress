//
//  CoinPickerView.swift
//  钱条
//
//  Created by Lakr Aream on 2022/3/22.
//

import SwiftUI

struct CoinTypePicker: View {
    @Environment(\.presentationMode) var presentationMode

    let onLoad: () -> (String)
    let onComplete: (String) -> Void

    var gridItem = [GridItem(.adaptive(minimum: 45, maximum: 75))]

    @State var unit: String = ""

    @State var search: String = ""

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Select Currency Type")
                    .font(.system(.headline, design: .rounded))
                Spacer()
            }
            Divider()
            HStack {
                Text("search".localized)
                TextField("", text: $search)
            }
            ScrollView {
                LazyVGrid(columns: gridItem, alignment: .center) {
                    ForEach(currencyModels, id: \.self) { item in
                        if search.isEmpty || item.AlphabeticCode.lowercased().contains(search.lowercased()) {
                            Text(item.AlphabeticCode)
                                .underline()
                                .font(.system(.subheadline, design: .rounded))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(4)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(4)
                                .onTapGesture {
                                    onComplete(item.AlphabeticCode)
                                    presentationMode.wrappedValue.dismiss()
                                }
                                .onHover { h in
                                    if h {
                                        NSCursor.pointingHand.push()
                                    } else {
                                        NSCursor.pop()
                                    }
                                }
                        }
                    }
                }
            }
            Divider()
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel".localized)
                }
                Spacer()
            }
        }
        .padding()
        .frame(width: 600, height: 400, alignment: .center)
    }
}
