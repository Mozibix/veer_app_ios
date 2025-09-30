//
//  Logger.swift
//  Veer
//
//  Created by Apple on 9/19/25.
//

import Foundation

enum Logger {
    /// Pretty-print a dictionary
    static func log(_ title: String = "📦 Full Data", _ dictionary: [String: Any],) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8)
        {
            print("\(title):\n\(jsonString)")
        } else {
            print("⚠️ Failed to pretty print dictionary: \(dictionary)")
        }
    }

    /// Pretty-print Codable objects
    static func log<T: Codable>(_ title: String = "📦 Full Object", _ object: T,) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(object),
           let jsonString = String(data: jsonData, encoding: .utf8)
        {
            print("\(title):\n\(jsonString)")
        } else {
            print("⚠️ Failed to pretty print object")
        }
    }

    /// Pretty-print raw JSON Data
    static func log(_ title: String = "📦 Full JSON Data", _ data: Data,) {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8)
        {
            print("\(title):\n\(jsonString)")
        } else {
            print("⚠️ Failed to pretty print raw data")
        }
    }
}
