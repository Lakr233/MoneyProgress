//
//  ContentView.swift
//  MoneyProgress
//
//  Created by Lakr Aream on 2022/3/14.
//

import Colorful
import SwiftUI

struct ContentView: View {
    // store timestamp at 1970.1.1
    // we are using the time components only

    @AppStorage("wiki.qaq.workStart")
    var __workStart: Double = 0

    @AppStorage("wiki.qaq.workEnd")
    var __workEnd: Double = 0

    @AppStorage("wiki.qaq.monthPaid")
    var __monthPaid: Int = 20000

    @AppStorage("wiki.qaq.dayWorkOfMonth")
    var __dayWorkOfMonth: Int = 20

    @State var workStart: Double = 0
    @State var workEnd: Double = 0
    @State var monthPaid: Int = 0
    @State var sliderWidth: CGFloat = 0
    @State var dayWorkOfMonth: Int = 20

    @StateObject var menubar = Menubar.shared

    var body: some View {
        ZStack {
            ColorfulView(
                colors: [Color.accentColor],
                colorCount: 4
            )
            .opacity(0.25)
            appIntro
                .padding()
        }
        .frame(width: 700, height: 400, alignment: .center)
        .onAppear {
            if __workStart == 0 || __workEnd == 0 {
                fillInitialData()
            } else {
                workStart = __workStart
                workEnd = __workEnd
                monthPaid = __monthPaid
            }
        }
        .onChange(of: workStart) { newValue in
            __workStart = newValue
            Menubar.shared.reload()
        }
        .onChange(of: workEnd) { newValue in
            __workEnd = newValue
            Menubar.shared.reload()
        }
        .onChange(of: monthPaid) { newValue in
            __monthPaid = newValue
            Menubar.shared.reload()
        }
        .onChange(of: dayWorkOfMonth) { newValue in
            __dayWorkOfMonth = newValue
            Menubar.shared.reload()
        }
    }

    func fillInitialData() {
        let date = Date()
        let calendar = Calendar.current
        let dateComponentsBegin = DateComponents(
            calendar: Calendar.current,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: 9,
            minute: 0,
            second: 0
        )
        workStart = dateComponentsBegin.date?.timeIntervalSince1970 ?? 0
        let dateComponentsEnd = DateComponents(
            calendar: Calendar.current,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: 21,
            minute: 0,
            second: 0
        )
        workEnd = dateComponentsEnd.date?.timeIntervalSince1970 ?? 0
        dayWorkOfMonth = 20
    }

    var rmbPreSecond: Double {
        let interval = Date(timeIntervalSince1970: workEnd)
            .timeIntervalSince(Date(timeIntervalSince1970: workStart))
        return Double(monthPaid)
            / Double(dayWorkOfMonth) /* days */
            / interval /* second each day */
    }

    var appIntro: some View {
        VStack(alignment: .center, spacing: 15) {
            Image("avatar")
                .resizable()
                .antialiased(true)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
            VStack(spacing: 6) {
                Text("钱条")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                Text("挣钱的进度条，得是老板给我的欠条。")
                    .font(.system(.headline, design: .rounded))
            }
            progressBar
                .frame(maxWidth: 400)
            HStack {
                Text("月薪 ")
                TextField("这条子够长了吧", text: Binding<String>(get: {
                    String(monthPaid)
                }, set: { str in
                    monthPaid = Int(str) ?? 0
                }))
                .frame(width: 100)
                Text("RMB")
                Spacer()
                Text("一个月工作 ")
                TextField("这条子够长了吧", text: Binding<String>(get: {
                    String(dayWorkOfMonth)
                }, set: { str in
                    dayWorkOfMonth = Int(str) ?? 0
                }))
                .frame(width: 50)
                Text("天")
            }
            .font(.system(.subheadline, design: .rounded))
            .frame(maxWidth: 400)
            Text("这么看来，假设一个月工作 \(dayWorkOfMonth) 天，您一秒钟能挣 \(rmbPreSecond) 元！")
                .font(.system(.headline, design: .rounded))

            Button {
                if menubar.menubarRunning {
                    menubar.stop()
                } else {
                    menubar.run()
                }
            } label: {
                if menubar.menubarRunning {
                    Text("从状态栏撤下来！")
                } else {
                    Text("立即挂到状态栏开始计价！")
                }
            }

            Spacer()

            HStack {
                Spacer()
                Button {
                    fillInitialData()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    func twoDigit(_ i: Int) -> String {
        if i < 10 {
            return "0\(i)"
        } else {
            return String(i)
        }
    }

    var offsetForBegin: CGFloat {
        let percent = Date(timeIntervalSince1970: workStart)
            .minSinceMidnight / (24 * 60)
        let ret = sliderWidth * (percent - 0.5)
        debugPrint(ret)
        return ret
    }

    var offsetForEnd: CGFloat {
        let percent = Date(timeIntervalSince1970: workEnd)
            .minSinceMidnight / (24 * 60)
        let ret = sliderWidth * (percent - 0.5)
        debugPrint(ret)
        return ret
    }

    var minPerPixel: CGFloat {
        let ret: CGFloat = 24 * 60 / sliderWidth
        debugPrint("minPerPixel: \(ret)")
        return ret
    }

    var progressBar: some View {
        VStack {
            GeometryReader { r in
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.9)
                    .cornerRadius(6)
                    .overlay(
                        HStack {
                            Spacer()
                            ForEach(1 ..< 24, id: \.self) { _ in
                                Rectangle()
                                    .frame(width: 0.5)
                                    .foregroundColor(.black)
                                    .opacity(0.1)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    )
                    .overlay(
                        Rectangle()
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                            .frame(width: 8, height: 25)
                            .shadow(radius: 0.5)
                            .offset(x: offsetForBegin)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged {
                                        let shift = ($0.location.x - 4) + sliderWidth / 2
                                        let mins = Double(shift * minPerPixel)
                                        let newStamp = updateDate(minsFromMidnight: mins)
                                        workStart = newStamp
                                    }
                            )
                    )
                    .overlay(
                        Rectangle()
                            .foregroundColor(.green)
                            .cornerRadius(8)
                            .frame(width: 8, height: 25)
                            .shadow(radius: 0.5)
                            .offset(x: offsetForEnd)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged {
                                        let shift = ($0.location.x - 4) + sliderWidth / 2
                                        let mins = Double(shift * minPerPixel)
                                        let newStamp = updateDate(minsFromMidnight: mins)
                                        workEnd = newStamp
                                    }
                            )
                    )
                    .onAppear {
                        sliderWidth = r.size.width
                    }
                    .onChange(of: r.size) { newValue in
                        if sliderWidth != newValue.width {
                            sliderWidth = newValue.width
                            debugPrint(sliderWidth)
                        }
                    }
            }
            .frame(height: 30)
            HStack {
                Text("上班于 " + createTimeDescription(workStart))
                Spacer()
                Text("下班于 " + createTimeDescription(workEnd))
            }
            .font(.system(.caption, design: .rounded))
        }
    }

    func updateDate(minsFromMidnight mins: Double) -> Double {
        let date = Date()
        let calendar = Calendar.current
        let comps = DateComponents(
            calendar: calendar,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: Int(mins / 60),
            minute: Int(mins.truncatingRemainder(dividingBy: 60)),
            second: 0
        )
        return comps.date?.timeIntervalSince1970 ?? 0
    }

    func createTimeDescription(_ from: Double) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .none // set as desired
        fmt.timeStyle = .medium // set as desired
        return fmt.string(from: Date(timeIntervalSince1970: from))
    }
}

extension Date {
    var dayAfter: Date { Calendar.current.date(byAdding: .day, value: 1, to: noon)! }
    var noon: Date { Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)! }
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var endOfDay: Date { Calendar.current.date(byAdding: .init(second: -1), to: dayAfter.startOfDay)! }
    var minSinceMidnight: Double {
        let calendar = Calendar.current
        return Double(calendar.component(.hour, from: self) * 60
            + calendar.component(.minute, from: self))
    }
}

struct MainPreview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
