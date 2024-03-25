//
//  AppError.swift
//  GoogleBooksAPI
//
//  Created by Leena Alsayari on 7/3/23.
//

import Foundation

enum AppError: Error {
    case unauthenticated
    case invalidJSONResponse
    case couldNotParseJSON(rawError: Error) //wrap as an associated value
    case noInternetConnection
    case badURL
    case badStatusCode
    case noDataReceived
    case other(rawError: Error)
}
