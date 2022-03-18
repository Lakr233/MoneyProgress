//
//  MenubarView.swift
//  MoneyProgress
//
//  Created by Lakr Aream on 2022/3/15.
//

import SwiftUI

struct MenubarView: View {
    @StateObject var menubar = Menubar.shared

    let myTitle = [
        "一起摸鱼！",
        "摸！都可以摸！",
        "Always Day 1, Always Touch Fish!",
    ]

    let currentTitle: String

    @AppStorage("wiki.qaq.currencyUnit")
    var currencyUnit: String = "RMB"

    init() {
        currentTitle = myTitle.randomElement()!
    }

    var body: some View {
        ZStack {
            content
                .padding()
        }
        .frame(width: 400, height: 200)
    }

    var content: some View {
        VStack(spacing: 10) {
            Text("💰")
                .font(.largeTitle)
            Group {
                if menubar.todayPercent <= 0 {
                    Text("No work started today!")
                } else if menubar.todayPercent >= 0 {
                    Text(currentTitle)
                } else {
                    Text("You have earned your full salary today!")
                }
            }
            .font(.headline)

            HStack {
                Text("Today's Progress")
                Spacer()
                Text(String(format: "%.4f", menubar.todayPercent * 100))
                Text("%")
            }
            .font(.system(.caption, design: .monospaced))

            GeometryReader { r in
                Rectangle()
                    .foregroundColor(.white)
                    .overlay(
                        HStack(spacing: 0) {
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: r.size.width * menubar.todayPercent)
                            if menubar.todayPercent < 1 {
                                Spacer()
                            }
                        }
                    )
                    .cornerRadius(4)
            }
            .frame(height: 15)

            HStack {
                Text("预计今日一共挣钱 \(menubar.todayEarn) \(currencyUnit)")
                Spacer()
            }
            .font(.system(.caption, design: .monospaced))

            Button {
                exit(0)
            } label: {
                Circle()
                    .foregroundColor(.black)
                    .opacity(0.1)
                    .padding(4)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    )
                    .padding(4)
            }
            .frame(width: 40, height: 40)
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct MenubarView_Previews: PreviewProvider {
    static var previews: some View {
        MenubarView()
    }
}
