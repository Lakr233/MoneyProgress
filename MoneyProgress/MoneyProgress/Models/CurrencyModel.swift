//
//  CurrencyModel.swift
//  MoneyProgress
//
//  Created by lialong on 17/03/2022.
//

import Foundation

struct CurrencyModel: Hashable, Codable, Identifiable {
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
    var id: Int?
    var AlphabeticCode: String?
    var Currency: String
    var Entity: String
    var MinorUnit: String?
    var NumericCode: Int?
    var WithdrawalDate: String?
}
