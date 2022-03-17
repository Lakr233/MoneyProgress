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
    
    @AppStorage("wiki.qaq.noonBreakStartTimeStamp")
    var __noonBreakStartTimeStamp: Double = 0
    @AppStorage("wiki.qaq.noonBreakEndTimeStamp")
    var __noonBreakEndTimeStamp: Double = 0
    
    @AppStorage("wiki.qaq.monthPaid")
    var __monthPaid: Int = 3000
    
    @AppStorage("wiki.qaq.dayWorkOfMonth")
    var __dayWorkOfMonth: Int = 20
    
    @AppStorage("wiki.qaq.isHaveNoonBreak")
    var __isHaveNoonBreak: Bool = false

    @AppStorage("wiki.qaq.compactMode")
    var compactMode: Bool = false
    
    @AppStorage("wiki.qaq.currencyUnit")
    var __currencyUnit: String = "RMB"
    
    @State var workStartTimeStamp: Double = 0
    @State var workEndTimeStamp: Double = 0
    
    @State private var workStartDate: Date = Date()
    @State private var workEndDate: Date = Date()
    
    @State private var noonBreakStartDate: Date = Date()
    @State private var noonBreakEndDate: Date = Date()
    
    @State var monthPaid: Int = 0
    @State var sliderWidth: CGFloat = 0
    @State var dayWorkOfMonth: Int = 20
    
    @StateObject var menubar = Menubar.shared
    
    @State private var isHaveNoonBreak: Bool = false
    @State private var isShowAlert = false
    @State private var isMoneyInvalid = false
    @State private var isWorkDayInvalid = false
    
    @State private var currencyUnit = "RMB"
    
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
        .frame(width: 700, height: 500, alignment: .center)
        .onAppear {
            if __workStart == 0 || __workEnd == 0 {
                fillInitialData()
            } else {
                workStartTimeStamp = __workStart
                workEndTimeStamp = __workEnd
                workStartDate = Date.init(timeIntervalSince1970: __workStart)
                workEndDate = Date.init(timeIntervalSince1970: __workEnd)
                noonBreakStartDate = Date.init(timeIntervalSince1970: __noonBreakStartTimeStamp)
                noonBreakEndDate = Date.init(timeIntervalSince1970: __noonBreakEndTimeStamp)
                monthPaid = __monthPaid
                isHaveNoonBreak = __isHaveNoonBreak
                currencyUnit = __currencyUnit
            }
        }
        .onChange(of: workStartDate) { newValue in
            __workStart = newValue.timeIntervalSince1970
            Menubar.shared.reload()
        }
        .onChange(of: workEndDate) { newValue in
            __workEnd = newValue.timeIntervalSince1970
            Menubar.shared.reload()
        }
        .onChange(of: noonBreakStartDate) { newValue in
            __noonBreakStartTimeStamp = newValue.timeIntervalSince1970
            Menubar.shared.reload()
        }
        .onChange(of: noonBreakEndDate) { newValue in
            __noonBreakEndTimeStamp = newValue.timeIntervalSince1970
            Menubar.shared.reload()
        }
        .onChange(of: monthPaid) { newValue in
            __monthPaid = newValue
            if newValue < 0 {
                self.isMoneyInvalid = true
            } else {
                self.isMoneyInvalid = false
            }
            Menubar.shared.reload()
        }
        .onChange(of: dayWorkOfMonth) { newValue in
            __dayWorkOfMonth = newValue
            if newValue <= 0 || newValue >= 32 {
                self.isWorkDayInvalid = true
            } else {
                self.isWorkDayInvalid = false
            }
            Menubar.shared.reload()
        }
        .onChange(of: isHaveNoonBreak) { newValue in
            __isHaveNoonBreak = newValue
            Menubar.shared.reload()
        }
        .onChange(of: currencyUnit) { newValue in
            __currencyUnit = newValue
            Menubar.shared.reload()
        }
    }
    
    func fillInitialData() {
        let date = Date()
        
        workStartTimeStamp = self.getTodayDate(hour: 9)?.timeIntervalSince1970 ?? 0
        workStartDate = self.getTodayDate(hour: 9) ?? date
        
        noonBreakStartDate = self.getTodayDate(hour: 12) ?? date
        
        noonBreakEndDate = self.getTodayDate(hour: 14) ?? date
        
        workEndTimeStamp = self.getTodayDate(hour: 18)?.timeIntervalSince1970 ?? 0
        workEndDate = self.getTodayDate(hour: 18) ?? date
        
        isHaveNoonBreak = false
        
        dayWorkOfMonth = 20
        
        currencyUnit = "RMB"
    }
    
    func getTodayDate(hour: Int, minute: Int = 0, second: Int = 0) -> Date? {
        let date = Date()
        let calendar = Calendar.current
        
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: hour,
            minute: minute,
            second: second
        )
        return dateComponents.date
    }
    
    var rmbPerSecond: Double {
        var timeInterval: TimeInterval = 1
        if isHaveNoonBreak {
            // interval = (workEndDate - noonBreakEndDate) + (noonBreakStartDate - workStartDate)
            timeInterval = workEndDate.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
        } else {
            // interval = workEndDate - workStartDate
            timeInterval = workEndDate.timeIntervalSince(workStartDate)
        }
        debugPrint(timeInterval)
        return Double(monthPaid)
        / Double(dayWorkOfMonth) /* days */
        / timeInterval /* second each day */
    }
    
    var workHours: String {
        var timeInterval: TimeInterval = 0
        if isHaveNoonBreak {
            timeInterval = workEndDate.timeIntervalSince(noonBreakEndDate) + noonBreakStartDate.timeIntervalSince(workStartDate)
        } else {
            timeInterval = workEndDate.timeIntervalSince(workStartDate)
        }
        let hours = timeInterval / 3600.0
        return String.init(format: "%.1f", hours)
    }
    
    var formattedRMBPerSecond: String {
        return String.init(format: "%.4f", self.rmbPerSecond)
    }
    
    var rmbPerDay: Double {
        return Double(monthPaid) / Double(dayWorkOfMonth)
    }
    
    var formattedRMBPerDay: String {
        return String.init(format: "%.2f", self.rmbPerDay)
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
                .frame(width: 80)
                Text(currencyUnit)
                Menu("货币单位") {
                    ForEach(validCurrencyModels, id: \.self) { currencyModel in
                        if let currencyUnit = currencyModel.AlphabeticCode {
                            Button(currencyUnit) {
                                self.currencyUnit = currencyUnit
                            }
                        }
                    }
                }.menuStyle(.borderedButton)
//                Spacer()
                Text("一个月工作 ")
                TextField("这条子够长了吧", text: Binding<String>(get: {
                    String(dayWorkOfMonth)
                }, set: { str in
                    dayWorkOfMonth = Int(str) ?? 0
                }))
                .frame(width: 40)
                Text("天")
            }
            .font(.system(.subheadline, design: .rounded))
            .frame(maxWidth: 400)
            let descriptionText = """
                            这么看来，假设一个月工作 \(dayWorkOfMonth) 天！\n \
                            您一天能挣 \(formattedRMBPerDay) \(currencyUnit)！\n \
                            您一天有效工时 \(workHours) 小时！\n \
                            您一秒钟能挣 \(formattedRMBPerSecond) \(currencyUnit)!
            """
            Text(descriptionText)
                .frame(width: 700, height: 80, alignment: .center)
                .font(.system(.headline, design: .rounded))
                .lineLimit(4)
            
            
            Button {
                if isMoneyInvalid || isWorkDayInvalid {
                    isShowAlert = true
                    return
                }
                
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
            .alert(isPresented: $isShowAlert) {
                if self.isMoneyInvalid {
                    return Alert(
                        title: Text("就这？"),
                        message: Text("💰 赚钱为负，上什么班？请检查自己的工资是否为负。")
                    )
                } else {
                    return Alert(
                        title: Text("就这？"),
                        message: Text("💰 您一个月到底工作几天？请检查自己的工作天数是否合理。")
                    )
                }
            }

            Toggle(isOn: $compactMode) {
              Text("紧凑模式")
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    fillInitialData()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.accentColor)
                    Text("恢复默认（朝九晚六）")
                        .fontWeight(.semibold)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 44)
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
        let percent = Date(timeIntervalSince1970: workStartTimeStamp)
            .minSinceMidnight / (24 * 60)
        let ret = sliderWidth * (percent - 0.5)
        debugPrint(ret)
        return ret
    }
    
    var offsetForEnd: CGFloat {
        let percent = Date(timeIntervalSince1970: workEndTimeStamp)
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
                                        workStartTimeStamp = newStamp
                                        workStartDate = Date.init(timeIntervalSince1970: newStamp)
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
                                        workEndTimeStamp = newStamp
                                        workEndDate = Date.init(timeIntervalSince1970: newStamp)
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
                DatePicker("上班于", selection: $workStartDate, displayedComponents: .hourAndMinute)
                Spacer()
                DatePicker("下班于", selection: $workEndDate, displayedComponents: .hourAndMinute)
            }
            .font(.system(.caption, design: .rounded))
            HStack {
                Toggle("是否有午休", isOn: $isHaveNoonBreak)
                    .toggleStyle(.checkbox)
                Spacer()
            }
            
            if isHaveNoonBreak {
                HStack {
                    DatePicker("午休开始于 ", selection: $noonBreakStartDate, displayedComponents: .hourAndMinute)
                    Spacer()
                    DatePicker("午休结束于 ", selection: $noonBreakEndDate, displayedComponents: .hourAndMinute)
                }
                .font(.system(.caption, design: .rounded))
            }
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
