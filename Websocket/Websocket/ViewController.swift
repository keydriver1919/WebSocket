//
//  ViewController.swift
//  Websocket
//
//  Created by change on 2021/12/27.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    @IBOutlet weak var socketButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var priceBTC: UILabel!
    @IBOutlet weak var priceICMARKETS: UILabel!
    @IBOutlet weak var priceApple: UILabel!
    @IBOutlet weak var priceAmazon: UILabel!
    
    private var webSocket: URLSessionWebSocketTask?
    
    let url = URL(string: "wss://ws.finnhub.io?token=c5fertiad3i9cg8u0ukg")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //開啟連線
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
        
        print("開啟連線")
        pingpong()
        receiveMessage()
        
        sendAMZN()
        sendICMARKETS()
        sendAAPL()
        sendBINANCEBTCUSDT()
        
        
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        close()
    }
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
    
    
    //連線
    @IBAction func socketButton(_ sender: Any) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
        print("開啟連線")
        pingpong()
        receiveMessage()
        
        sendAMZN()
        sendICMARKETS()
        sendAAPL()
        sendBINANCEBTCUSDT()
        
    }
    
    
    //心跳（確保連線）
    func pingpong() {
        webSocket?.sendPing { (error) in
            if let error = error {
                print("發送需求心跳錯誤： \(error)")
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.pingpong()
            }
        }
    }
    
    
    
    //發送請求
    func sendAMZN() {
        let string = "{\"type\":\"subscribe\",\"symbol\":\"AMZN\"}"
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocket?.send(message) { error in
            if let error = error {
                print("發送需求錯誤1： \(error)")
            }
        }
    }
    func sendICMARKETS() {
        let string = "{\"type\":\"subscribe\",\"symbol\":\"IC MARKETS:1\"}"
        
        let message = URLSessionWebSocketTask.Message.string(string)
        //print("\(message)")
        webSocket?.send(message) { error in
            if let error = error {
                print("發送需求錯誤2： \(error)")
            }
        }
    }
    func sendAAPL() {
        let string = "{\"type\":\"subscribe\",\"symbol\":\"AAPL\"}"
        
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocket?.send(message) { error in
            if let error = error {
                print("發送需求錯誤3： \(error)")
            }
        }
    }
    func sendBINANCEBTCUSDT() {
        let string = "{\"type\":\"subscribe\",\"symbol\":\"BINANCE:BTCUSDT\"}"
        
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocket?.send(message) { error in
            if let error = error {
                print("發送需求錯誤4： \(error)")
            }
        }
    }
    
    
    //接收
    func receiveMessage() {
        webSocket?.receive {[weak self] result in
            
            switch result {
            case .failure(let error):
                print("接收錯誤： \(error)")
                
            case .success(.string(let str)):
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(APIResponse.self, from: Data(str.utf8))
                    DispatchQueue.main.async{
                    
                        let resultSymbol = result.data[0].s
                        switch resultSymbol{
                        case "BINANCE:BTCUSDT":
                            self?.priceBTC.text = "\(result.data[0].p)"
                        case "IC MARKETS:1":
                            self?.priceICMARKETS.text = "\(result.data[0].p)"
                        case "AAPL":
                            self?.priceApple.text = "\(result.data[0].p)"
                        case "AMZN":
                            self?.priceAmazon.text = "\(result.data[0].p)"
                        default:
                            print("沒有比對到")
                        }
                        
                    }
                } catch  {
                    print("接收信息有些沒抓到，錯誤是： \(error.localizedDescription)")
                }
                
                self?.receiveMessage()
                
            default:
                print("默認")
            }
        }
    }
    
    
    
}



struct APIResponse: Codable {
    var data: [PriceData]
    var type : String
    
    private enum CodingKeys: String, CodingKey {
        case data, type
    }
}

struct PriceData : Codable{
    
    public var p: Float
    public var s: String
    
    private enum CodingKeys: String, CodingKey {
        case p
        case s
    }
}
