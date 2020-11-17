//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(btcPrice: Double)
    func didFailWithError(_ cointManager: CoinManager, error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "B057FBF0-7CC6-4046-AF96-9FA9DA3AF9CE"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        self.performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        // Create a url
        if let url = URL(string: urlString){
            // Create a session
            let session = URLSession(configuration: .default)
            // Create a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(self, error: error!)
                    return
                }
                if let safeData = data {
                    if let lastPrice = parseJSON(safeData) {
                        delegate?.didUpdateCoin(btcPrice: lastPrice)
                    }
                }
            }
            
            // Start task
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let rate = decodedData.rate
            
            return rate
            
        } catch  {
            delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
    
}
