//
//  StringExtension.swift
//  钱条
//
//  Created by lialong on 18/03/2022.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
