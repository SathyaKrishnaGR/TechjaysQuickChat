////
////  FayvEnvironment.swift
////  Fayvit
////
////  Created by Sharran on 9/12/20.
////  Copyright © 2020 Iderize. All rights reserved.
////
//
//import Foundation
//
//let fayvEnvironment: FayvEnvironment = .development
//let locale = Locale.current
//let region = locale.regionCode ?? ""
//
///// Fayvit Environment properties
//enum FayvEnvironment: CaseIterable {
//    case development
//    case staging
//    case production
//    
//    var baseUrl: String {
//        let regionCode = Region(rawValue: region)
//        switch regionCode {
//        case .IN:
//            switch self {
//            case .development: return "https://sprint.myvidhire.com/"
//            case .staging: return "https://staging.myvidhire.com/"
//            case .production: return "https://staging.myvidhire.com/"
//            }
//        default:
//            switch self {
//            case .development: return "https://sprint.myvidhire.com/"
//            case .staging: return "https://staging.myvidhire.com/"
//            case .production: return "https://staging.myvidhire.com/"
//            }
//        }
//    }
//    
//    var subdomain: String {
//        let regionCode = Region(rawValue: region)
//        switch regionCode {
//        case .IN:
//            switch self {
//            case .development: return "dev"
//            case .staging: return "stgin"
//            case .production: return "stgin"
//            }
//        default:
//            switch self {
//            case .development: return "dev"
//            case .staging: return "stg"
//            case .production: return "stg"
//            }
//        }
//    }
//    
//    var fetchLimit: Int { return 10 }
//}
//
//enum Region: String {
//    case IN
//}
//
//extension FayvEnvironment {
//    static func runOnDebug(run: () -> Void) {
//        #if DEBUG
//        run()
//        #endif
//    }
//}
