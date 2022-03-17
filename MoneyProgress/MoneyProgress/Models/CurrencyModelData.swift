//
//  CurrencyModelData.swift
//  MoneyProgress
//
//  Created by lialong on 17/03/2022.
//

import Foundation

var currencyModels: [CurrencyModel] = load("ISO_4217_Currency _Codes.json")
var validCurrencyModels = currencyModels.filter { currencyModel in
    if currencyModel.AlphabeticCode != nil {
        return true
    } else {
        return false
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
