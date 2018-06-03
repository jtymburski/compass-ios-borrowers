//
//  PaymentHelper.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-02.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

struct PaymentHelper {
    // Static variables
    private static let DAYS_PER_YEAR: Float = 365.0
    private static let MONTHS_PER_YEAR: Float = 12.0

    static func paymentPerPeriod(principal: Int, rate: Float, frequency: LoanFrequency, term: LoanAmortization) -> NSNumber {

        let totalYears = term.getTotalYears(monthsPerYear: MONTHS_PER_YEAR)
        let periodsPerYear = frequency.getPeriodsPerYear(daysPerYear: DAYS_PER_YEAR, monthsPerYear: MONTHS_PER_YEAR)
        let ratePerPeriod = powf(1 + rate / DAYS_PER_YEAR, DAYS_PER_YEAR / periodsPerYear) - 1
        print("INFO: \(totalYears) , \(periodsPerYear) , \(ratePerPeriod)")

        return NSNumber(value: Float(principal) * ratePerPeriod / (1 - powf(1 + ratePerPeriod, -periodsPerYear * totalYears)))
    }
}
