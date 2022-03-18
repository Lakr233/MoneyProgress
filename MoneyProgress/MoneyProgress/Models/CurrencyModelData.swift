//
//  CurrencyModelData.swift
//  MoneyProgress
//
//  Created by lialong on 17/03/2022.
//

import Foundation

var currencyModels: [CurrencyModel] = {
    let fn = "ISO_4217_Currency _Codes.json"
    debugPrint("loading items at \(fn)")
    let decoder = JSONDecoder()
    guard let file = Bundle.main.url(forResource: fn, withExtension: nil),
          let data = try? Data(contentsOf: file),
          let values = try? decoder.decode([OptionalCurrencyModel].self, from: data)
    else {
        print("failed to load json file")
        /*
         ▿ OptionalCurrencyModel
           - id : nil
           ▿ AlphabeticCode : Optional<String>
             - some : "CNY"
           - Currency : "Yuan Renminbi"
           - Entity : "CHINA"
           ▿ MinorUnit : Optional<String>
             - some : "2"
           ▿ NumericCode : Optional<Int>
             - some : 156
           - WithdrawalDate : nil
         */
        return [CurrencyModel(
            AlphabeticCode: "CNY",
            Currency: "Yuan Renminbi",
            Entity: "CHINA",
            MinorUnit: "2",
            NumericCode: 156,
            WithdrawalDate: ""
        )]
    }
    return values
        .compactMap { CurrencyModel(from: $0) }
        .sorted { $0.AlphabeticCode < $1.AlphabeticCode }
}()
