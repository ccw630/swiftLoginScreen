//
//  HomeVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.

//  Edited by ccw630

import UIKit

class HomeVC: UIViewController {

    @IBOutlet var usernameLabel : UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var txtPrice: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:UserDefaults = UserDefaults.standard
        let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegue(withIdentifier: "goto_login", sender: self)
        } else {
            self.usernameLabel.text = prefs.value(forKey: "USERNAME") as? String
            let sss = prefs.value(forKey: "SCORE") as? NSInteger
            self.scoreLabel.text = sss!.description
            print(prefs.value(forKey: "USERNAME")!)
            print(prefs.value(forKey: "SCORE")!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logoutTapped(_ sender : UIButton) {
        
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        
        self.performSegue(withIdentifier: "goto_login", sender: self)
    }
    @IBAction func buy1Tapped(_ sender : UIButton) {
        
        let username:NSString = usernameLabel.text! as NSString
        let score:NSString = txtPrice.text! as NSString
            do {
                let post:NSString = "buy=\(score)&&username=\(username)" as NSString
                
                print("PostData: %@",post);
                
                let url:URL = URL(string:"http://192.168.199.157/login/buy.php")!
                
                let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
                
                let postLength:NSString = String( postData.count ) as NSString
                
                let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var responseError: NSError?
                var response: URLResponse?
                
                var urlData: Data?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
                } catch let error as NSError {
                    responseError = error
                    urlData = nil
                }
                
                if ( urlData != nil ) {
                    let res = response as! HTTPURLResponse!;
                    
                    print("Response code: %ld", res?.statusCode);
                    
                    if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                        
                        print("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.value(forKey: "success") as! NSInteger
                        let score:NSInteger = jsonData.value(forKey: "score") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue];
                        
                        print("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            print("Buy SUCCESS");
                            self.scoreLabel.text = score.description
                            let alert = UIAlertController(title: "购买成功", message: "积分上升", preferredStyle: .alert)
                            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(OK)
                            self.present(alert, animated: true, completion: nil)
                         //   let prefs:UserDefaults = UserDefaults.standard
                         //   prefs.set(username, forKey: "USERNAME")
                         //   prefs.set(1, forKey: "ISLOGGEDIN")
                         //   prefs.synchronize()
                            
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            var errorMsg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                errorMsg = jsonData["error_message"] as! NSString
                            } else {
                                errorMsg = "未知错误"
                            }
                            let alert = UIAlertController(title: "购买失败", message:errorMsg as String, preferredStyle: .alert)
                            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(OK)
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    } else {
                        let alert = UIAlertController(title: "购买失败", message:"连接服务器失败", preferredStyle: .alert)
                        let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OK)
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "购买失败", message:"连接服务器失败:"+(responseError?.localizedDescription)!, preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OK)
                    self.present(alert, animated: true, completion: nil)
                }
            } catch {
                let alert = UIAlertController(title: "购买失败", message:"服务器出错了!", preferredStyle: .alert)
                let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
            }
        }
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}
