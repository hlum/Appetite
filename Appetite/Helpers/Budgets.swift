//
//  Budgets.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation

enum Budgets: String,FilterItemProtocol {
    case B009 = "～500円"
    case B010 = "501～1000円"
    case B011 = "1001～1500円"
    case B001 = "1501～2000円"
    case B002 = "2001～3000円"
    case B003 = "3001～4000円"
    case B008 = "4001～5000円"
    case B004 = "5001～7000円"
    case B005 = "7001～10000円"
    case B006 = "10001～15000円"
    case B012 = "15001～20000円"
    case B013 = "20001～30000円"
    case B014 = "30001円～"
    
    var name:String{
        self.rawValue
    }
    
    var code:String{
        String(describing: self)
    }
}
