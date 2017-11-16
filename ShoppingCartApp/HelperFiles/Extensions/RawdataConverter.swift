//
//  RawdataConverter.swift
//  manup
//
//  Created by Yudiz Solutions Pvt. Ltd. on 07/03/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit


/** A Converter class. Provide class type funcs for converting given object into appropriate type.
 */

class Converter {
    
    /** convert timestamp into Date object. 
        If timestamp object is invalid then return current date.
     */
    
    class func toDate(_ timestamp: Any?) -> Date? {
        if let any = timestamp {
            if let str = any as? NSString {
                return Date(timeIntervalSince1970: str.doubleValue)
            } else if let str = any as? NSNumber {
                return Date(timeIntervalSince1970: str.doubleValue)
            }
        }
        return nil
    }
    
    
    /** convert givent value in to Int.
        If given value is nil or not a numeric value then it will return 0.
    */
    
    class func toInt(_ anything: Any?) -> Int {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.intValue
            } else if let str = any as? NSString {
                return str.integerValue
            }
        }
        return 0
    }
    
    /** convert givent value in to UInt.
     If given value is nil or not a numeric value then it will return 0.
     */
    
    class func toUInt(_ anything: Any?) -> UInt {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.uintValue
            } else if let str = any as? NSString {
                return UInt(Int(str.intValue))
            }
        }
        return 0
    }
    
    /** convert givent value in to Double.
     If given value is nil or not a numeric value then it will return 0.
     */

    class func toDouble(_ anything: Any?) -> Double {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.doubleValue
            } else if let str = any as? NSString {
                return str.doubleValue
            }
        }
        return 0
        
    }
    
    /** convert givent value in to Float.
     If given value is nil or not a numeric value then it will return 0.
     */

    class func toFloat(_ anything: Any?) -> Float {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.floatValue
            } else if let str = any as? NSString {
                return str.floatValue
            }
        }
        return 0
        
    }
    
    /** convert givent value in to String.
     If given value is nil then it will return empty string.
     */

    class func toString(_ anything: Any?) -> String {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.stringValue
            } else if let str = any as? String {
                return str
            }
        }
        return ""
        
    }
    
    /** convert givent value in to Double.
     If given value is nil then it will return nil.
     */

    class func optionalString(_ anything: Any?) -> String? {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.stringValue
            } else if let str = any as? String {
                return str
            }
        }
        return nil
        
    }
    
    /** convert givent value in to Double.
     If given value is nil or not a numeric value then it will return 0.
     */

    class func toBool(_ anything: Any?) -> Bool {
        if let any = anything {
            if let num = any as? NSNumber {
                return num.boolValue
            } else if let str = any as? NSString {
                return str.boolValue
            }
        }
        return false
    }

}


