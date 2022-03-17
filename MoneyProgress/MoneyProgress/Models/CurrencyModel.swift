//
//  CurrencyModel.swift
//  MoneyProgress
//
//  Created by lialong on 17/03/2022.
//

import Foundation

struct OptionalCurrencyModel: Hashable, Codable, Identifiable {
    var id: Int?
    var AlphabeticCode: String?
    var Currency: String
    var Entity: String
    var MinorUnit: String?
    var NumericCode: Int?
    var WithdrawalDate: String?
}

struct CurrencyModel: Hashable, Codable, Identifiable {
    init?(from: OptionalCurrencyModel) {
        guard let AlphabeticCode = from.AlphabeticCode
        else {
            return nil
        }
        id = UUID()
        self.AlphabeticCode = AlphabeticCode
        Currency = from.Currency
        Entity = from.Entity
        MinorUnit = from.MinorUnit ?? ""
        NumericCode = from.NumericCode ?? 0
        WithdrawalDate = from.WithdrawalDate ?? ""
    }

    init(
        id: UUID = UUID(),
        AlphabeticCode: String,
        Currency: String,
        Entity: String,
        MinorUnit: String,
        NumericCode: Int,
        WithdrawalDate: String
    ) {
        self.id = id
        self.AlphabeticCode = AlphabeticCode
        self.Currency = Currency
        self.Entity = Entity
        self.MinorUnit = MinorUnit
        self.NumericCode = NumericCode
        self.WithdrawalDate = WithdrawalDate
    }

    /*
     {
     "AlphabeticCode":"CNY",
     "Currency":"Yuan Renminbi",
     "Entity":"CHINA",
     "MinorUnit":"2",
     "NumericCode":156,
     "WithdrawalDate":null
     }
     */
    var id: UUID
    var AlphabeticCode: String
    var Currency: String
    var Entity: String
    var MinorUnit: String
    var NumericCode: Int
    var WithdrawalDate: String
}
