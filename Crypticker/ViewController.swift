import UIKit
import CryptoCurrencyKit
import Alamofire

class ViewController: CurrencyDataViewController {
  
    // Labels
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var dayChangeLabel: UILabel!
    
    
    
    
    let dateFormatter: DateFormatter
  
  required init?(coder aDecoder: NSCoder) {
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE M/d"
    
    super.init(coder: aDecoder)
  }
  
  ///
  ///
  override func viewDidLoad() {
    super.viewDidLoad()
    
    lineChartView.dataSource = self
    lineChartView.delegate = self
    
    priceOnDayLabel.text = ""
    dayLabel.text = ""
    
    
    ///////
    // Currency formatter
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    
    // Percentage formatter
    let percFormatter = NumberFormatter()
    percFormatter.minimumFractionDigits = 0
    percFormatter.maximumFractionDigits = 2
    
    // Labels
    highLabel.text = "..."
    lowLabel.text = "..."
    dayChangeLabel.text = "..."
    
    // Calling API using Alamofire and putting it in dictionaries
    Alamofire.request("https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD").responseJSON { response in
        print(response)
        
        if let bitcoinJSON = response.result.value {
            let bitcoinObject:Dictionary = bitcoinJSON as! Dictionary<String, Any>
            
            // Parse through information
            let rawObject:Dictionary = bitcoinObject["RAW"] as! Dictionary<String, Any>
            let usdObject:Dictionary = rawObject["BTC"] as! Dictionary<String, Any>
            let btcObject:Dictionary = usdObject["USD"] as! Dictionary<String, Any>
            
            // Current price
            let rate:NSNumber = btcObject["PRICE"] as! NSNumber
            let rateCurrency = (formatter.string(from: rate)!)
            // Day change
            let dayChange:NSNumber = btcObject["CHANGE24HOUR"] as! NSNumber
            let dayChangeCurrency = (formatter.string(from: dayChange)!)
            // Day change percentage
            let dayChangePerc:NSNumber = btcObject["CHANGEPCT24HOUR"] as! NSNumber
            let dayChangePercPercentage = (percFormatter.string(from: dayChangePerc)!)
            // High day price
            let highDay:NSNumber = btcObject["HIGH24HOUR"] as! NSNumber
            let highDayCurrency = (formatter.string(from: highDay)!)
            // Low day price
            let lowDay:NSNumber = btcObject["LOW24HOUR"] as! NSNumber
            let lowDayCurrency =  (formatter.string(from: lowDay)!)
            
            // Changing UI
            self.priceLabel.text = "\(rateCurrency)" // Current price
            self.dayChangeLabel.text = "\(dayChangeCurrency)  (\(dayChangePercPercentage)%)"
            self.highLabel.text = "\(highDayCurrency)"
            self.lowLabel.text = "\(lowDayCurrency)"
        }
    }
    //////////
  }
  
  override func viewWillAppear(_ animated: Bool)  {
    super.viewWillAppear(animated)
    
    fetchPrices { error in
      if error == nil {
        self.updatePriceLabel()
        self.updatePriceChangeLabel()
        self.updatePriceHistoryLineChart()
      }
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    self.lineChartView.reloadData()
  }

  func updateDayLabel(_ price: BitCoinPrice) {
    dayLabel.text = dateFormatter.string(from: price.time)
  }
  
  // MARK: - JBLineChartViewDataSource & JBLineChartViewDelegate
  
  func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
    if let prices = prices {
      let price = prices[Int(horizontalIndex)]
      updatePriceOnDayLabel(price)
      updateDayLabel(price)
    }
  }
  
  func didUnselectLineInLineChartView(_ lineChartView: JBLineChartView!) {
    priceOnDayLabel.text = ""
    dayLabel.text = ""
  }
  
}

