//
//  LoginVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//
//  Edited by ccw630

import UIKit

class LoginVC: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func signinTapped(_ sender : UIButton) {
        let username:NSString = txtUsername.text! as NSString
        let password:NSString = txtPassword.text! as NSString
        
        if ( username.isEqual(to: "") || password.isEqual(to: "") ) {
            
            let alert = UIAlertController(title: "登录失败", message: "用户名和密码不能为空", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OK)
            self.present(alert, animated: true, completion: nil)
        } else {
            
            do {
            let post:NSString = "username=\(username)&password=\(password)" as NSString
            
            print("PostData: %@",post);
            
            let url:URL = URL(string:"http://localhost/login/jsonlogin2.php")!
            
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
                        print("Login SUCCESS");
                        
                        let prefs:UserDefaults = UserDefaults.standard
                        prefs.set(username, forKey: "USERNAME")
                        prefs.set(score, forKey: "SCORE")
                        prefs.set(1, forKey: "ISLOGGEDIN")
                        prefs.synchronize()
                        
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        var errorMsg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            errorMsg = jsonData["error_message"] as! NSString
                        } else {
                            errorMsg = "未知错误"
                        }
                        let alert = UIAlertController(title: "登录失败", message:errorMsg as String, preferredStyle: .alert)
                        let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OK)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    let alert = UIAlertController(title: "登录失败", message:"连接服务器失败", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OK)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "登录失败", message:"连接服务器失败:"+(responseError?.localizedDescription)!, preferredStyle: .alert)
                let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
            }
            } catch {                                                     let alert = UIAlertController(title: "登录失败", message:"服务器出错了!", preferredStyle: .alert)
                let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}
