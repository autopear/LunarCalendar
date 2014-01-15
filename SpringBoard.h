//SpringBoard headers for iOS 5 & 6
@interface SBBulletinListController : NSObject
+ (id)sharedInstance;
- (id)listView;
@end

@interface SBBulletinListView : UIView
- (id)linenView;
@end

//SpringBoard headers for iOS 7
@interface SBBulletinViewController : UITableViewController
@property(nonatomic) CGRect tableViewFrame;
@end

@interface SBBulletinObserverViewController : UIViewController {
    SBBulletinViewController *_bulletinViewController;
}
@property(readonly, nonatomic) SBBulletinViewController *bulletinViewController;
@end

@interface SBModeViewController : UIViewController {
    SBBulletinObserverViewController *_selectedViewController;
    UISwipeGestureRecognizer *_leftSwipeGestureRecognizer;
    UISwipeGestureRecognizer *_rightSwipeGestureRecognizer;
}
@property(readonly, nonatomic) SBBulletinObserverViewController *selectedViewController;
@end

@interface SBNotificationCenterViewController : UIViewController {
    SBModeViewController *_modeController;
}
@end

@interface SBNotificationCenterController : NSObject
@property(readonly, nonatomic) SBNotificationCenterViewController *viewController;
@end
