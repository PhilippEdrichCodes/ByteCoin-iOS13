//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation


protocol CoinManagerDelegate {
    func didUpdateExchangeRate(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager{
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io"
    let endPoint = "/v1/exchangerate"
    var asset = "BTC"
    let apiKey = "F08A66FA-0E1E-4A7E-AF0D-881F615CF58D"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)\(endPoint)/\(asset)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString, for: currency)
    }
    
    func performRequest(with urlString: String, for currency: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let price = self.parseJSON(safeData) {
                        
                        let priceString = String(format: "%.2f", locale: .current, price)
                        self.delegate?.didUpdateExchangeRate(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            
            return lastPrice
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
