//
//  AppDelegate.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 08/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit
import Fabric
import Crashlytics
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import KVAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var arrCategory = [Category]()
    var isBackToAddressScreen: Bool = false
    var isBackToAccountScreen: Bool = false
    var isTextFieldInput: Bool = false
    var isViewOrder: Bool = false
    var arrGiftCoupons = [GiftCouponList]()
    var selectedMinPrcie = 0
    var selectedMaxPrcie = 0
    
    let gcmMessageIDKey = "gcm.message_id"
	var productId = "0"
    weak var tabBarVC: TabBarVC!
    
    //master changes
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        //FCM
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .InstanceIDTokenRefresh,
                                               object: nil)
        
        //Fabric.with([Twitter.self])
        Twitter.sharedInstance().start(withConsumerKey: "k3c6nbtX6YhAfqxmL39HsbFtj", consumerSecret: "xCZRQpQce1qgECAtGtdzonLkfIgAxhlZv4YYdGhVIaav0cRpaG")
        self.getAuthToken()
        self.setLoggedInUser()
        
        UITabBar.appearance().tintColor = UIColor.darkGray
        FirRCManager.shared.fetchConfigurations()
        
        Fabric.with([Crashlytics.self, Twitter.self])
        return true
    }
    
    
    func setLoggedInUser() {
        if let userInfo = UserDefaults.standard.value(forKey: AppPreference.userObj) as? [String : Any]{
            dictUser = User(userInfo)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

	func applicationDidEnterBackground(_ application: UIApplication) {
		if productId != "0" {
			saveProductTime(flag: false)
		}
	}

	func saveProductTime(flag:Bool) {
		
		let apiParam = ["productId" : productId,"flag" :flag] as [String : Any]
		wsCall.productTimeSave(params: apiParam) { (response) in
			if response.isSuccess {

			}
		}
	}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "ShoppingCartApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getAuthToken() {
        
        /*grant_type=password&username=uc&password=azure&user_type=guest
         Content-Type:x-www-form-urlencoded
         token:Zem9vOObWkxMIMjM=1*/
        
        if let token = _userDefault.value(forKey: AppPreference.authToken) as? String  {
            wsCall.setClientToken(token:token)
        } else {
            let paramDict = ["grant_type":"password","username":"uc","password":"azure","user_type":"guest"] as [String:Any]
            wsCall.setClientToken(token: "Zem9vOObWkxMIMjM=1")
            wsCall.getAuthToken(params: paramDict) { (response) in
                if response.isSuccess {
                    if let json = response.json as? [String:Any] {
                        println("getAuthToken response is => \(json)")
                        if let accessToken1 = json["access_token"] as? String {
                            let accessToken =  (json["token_type"] as? String)! + " " + accessToken1
                            _userDefault.set(accessToken, forKey: AppPreference.authToken)
                            wsCall.setClientToken(token:accessToken)
                        }
                    }
                }
            }
            
        }
    }
    
    //MARK: - FireBase Open Url method
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = true
        if #available(iOS 9.0, *) {
            handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        } else {
            // Fallback on earlier versions
            handled = true
        }
        
        if #available(iOS 9.0, *) {
            GIDSignIn.sharedInstance().handle(url,
                                              sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!,
                                              annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        } else {
            // Fallback on earlier versions
        }
        //return Twitter.sharedInstance().application(app, open: url, options: options)
        return handled || Twitter.sharedInstance().application(app, open: url, options: options)
    }
    
    
    
    
    
}
//MARK:- FCM NOTIFICATION -
extension AppDelegate : UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        println("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        println("remote notification dictionary is", userInfo)
       // print("Body  is", userInfo["body"]!)
        var msg = ""
        if (userInfo["body"] != nil) {
            msg = userInfo["body"] as! String
        }
       
        KVAlertView.show(message: msg)
       // self.navigateToScreen(with : userInfo)
        
    }
    // Receive data message on iOS 10 devices while app is in the foreground.
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func application(received remoteMessage: MessagingRemoteMessage) {
        println(remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String){
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFcm()
        
        FBSDKAppEvents.activateApp()
    }
    
}
//MARK: - Remote (Push) Notification Setup.
extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            println("didReceiveRemoteNotification Message ID: \(messageID)")
        }
        
        println( "pppppppp didReceiveRemoteNotification user info",userInfo)
        self.navigateToScreen(with : userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        if UIApplication.shared.applicationState == .active {
            
        }
        else {
            
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        println("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            //call server side api to register fcm token at PM server
            self.registerFCMTokenAPICall()
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard InstanceID.instanceID().token() != nil else {
            return
        }
        
        
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().disconnect()
        
        Messaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    //API call for registring FCM token at global retailer server.
    func registerFCMTokenAPICall()
    {
        InstanceID.instanceID().getID { (id, error) in
            var instanceID = ""
            var fcmToken = ""
            if let id = id {
                instanceID = id
            }
            
            if let token = InstanceID.instanceID().token() {
                fcmToken = token
            }
            
            var userID = "1"
            /* if let dict = UserDefaults.standard.object(forKey: PMUserProfile) as? [String : Any] {
             // userID = dict["customerId"] as! String
             userID = "\(String(describing: dict["customerId"]))"
             
             }
             var params = ["deviceType" : "IOS",
             "instanceId" : instanceID,
             "token" : fcmToken]
             
             if !userID.isEmpty {
             params["userid"] = userID
             }*/
            
            /*  PMWebService.callPost(forApi: "Device", withRequestDict: params , successBlock: { (response) in
             print(response)
             }, errorBlock: { (error) in
             if let error = error as? NSError {
             if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? Data {
             let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
             print(json)
             }
             }
             })*/
            
            
        }
        
        
    }
    
}

extension AppDelegate {
    
    func navigateToScreen(with userInfo: [AnyHashable : Any]) {
        
        let notificationtype = Converter.toInt(userInfo["type"] as! String)
        
        let onScreenController = self.tabBarVC.viewControllers![self.tabBarVC.selectedIndex] as! UINavigationController
        
        switch notificationtype {
        case 1: //order
            let sbMyOrders = UIStoryboard(name: "MyOrders", bundle: Bundle(for: ParentViewController.self))
            let orderDetailVC = sbMyOrders.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
            orderDetailVC.orderId = Converter.toString(userInfo["orderId"])
            
            
           
            onScreenController.pushViewController(orderDetailVC, animated: true)
            
        case 2: //offer
            let sbOffer = UIStoryboard(name: "Offer", bundle: Bundle(for: ParentViewController.self))
            let offerVC = sbOffer.instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
            offerVC.strApiParam = Converter.toString(userInfo["apiParam"])
            onScreenController.pushViewController(offerVC, animated: true)
            
        case 3: //out of stock /Notify me
            
            let storyboardOffer = UIStoryboard(name: "Offer", bundle: Bundle(for: ParentViewController.self))
            let rvc = storyboardOffer.instantiateViewController(withIdentifier: "SBID_JustForYouVC") as! JustForYouVC
            onScreenController.pushViewController(rvc, animated: true)
           
            
           /* let productId = Converter.toString(userInfo["productId"])
            
            ProductDetailVC.showProductDetail(in: onScreenController.viewControllers[onScreenController.viewControllers.count - 1] as! ParentViewController, productId: productId , product:nil,isFromCart: false, identifier: nil, shouldShowTab: false)*/
            
        case 4: break //general
            
            
        default:
            break
        }
        
       
        
    }
    
    
}



