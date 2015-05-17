//
//  CHLAddressBookViewController.m
//  Chill
//
//  Created by Виктор Шаманов on 7/10/14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import "CHLAddressBookViewController.h"
#import "UIColor+ChillColors.h"
#import "CHLFriendCell.h"
#import "CHLShareViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

@interface CHLAddressBookUserInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, copy) NSString *phoneNumber;

- (id)initWithName:(NSString *)name lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber avatar:(UIImage *)avatar;

@end

@implementation CHLAddressBookUserInfo
- (id)initWithName:(NSString *)name lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber avatar:(UIImage *)avatar {
    if (self = [super init]) {
        _name = name;
        _phoneNumber = phoneNumber;
        _avatar = avatar;
        _lastName = lastName;
    }
    return self;
}
@end

@interface CHLAddressBookViewController () <MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSArray *users;

@end

@implementation CHLAddressBookViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // self.navigationController.view.layer.cornerRadius=6;
    self.navigationController.view.clipsToBounds=YES;
    self.tableView.tableFooterView = [UIView new];
    
    self.navigationController.navigationBar.barTintColor = [UIColor chillMintColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

NSInteger alphabeticSort(id string1, id string2, void *reverse)
{
    if (*(BOOL *)reverse == YES) {
        return [string2 localizedCaseInsensitiveCompare:string1];
    }
    return [string1 localizedCaseInsensitiveCompare:string2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Invite from address book screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted){
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
            CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
            
            NSMutableArray *mutableUsers = [NSMutableArray array];
            for (int i = 0; i < nPeople; i++)
            {
                ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
                
                NSString *name = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty)==nil?@"":(__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty)==nil?@"":(__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
                ABMultiValueRef phone = (__bridge ABMultiValueRef)((__bridge NSMutableDictionary *)ABRecordCopyValue(ref, kABPersonPhoneProperty));
                NSString *phoneNumber = ((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phone)).firstObject;
                UIImage *avatar = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail)];
                
                CHLAddressBookUserInfo *userInfo = [[CHLAddressBookUserInfo alloc] initWithName:name
                                                                                       lastName:lastName
                                                                                    phoneNumber:phoneNumber
                                                                                         avatar:avatar];
                
                [mutableUsers addObject:userInfo];
                
            }
//            BOOL reverseSort = NO;
//            NSData *sortedArrayHint = [mutableUsers sortedArrayHint];

          //  NSArray *arrayOfContacts = [mutableUsers copy];

            //[arrayOfContacts sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
           // [mutableUsers sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
            [mutableUsers sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.users = [mutableUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"phoneNumber != nil"]];
                [self.tableView reloadData];
            });
            
        });
    });
    
}

#pragma mark - Actions

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CHLAddressBookUserInfo *user = self.users[indexPath.row];
    
    
    NSString *cellIdentifier = user.avatar ? @"Cell" : @"Cell~";
    
    CHLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.avatarImageView.image = user.avatar;
    
    cell.avatarImageView.layer.cornerRadius = 18.0; 
    cell.avatarImageView.layer.masksToBounds = YES;
    
    NSString *name = [user.name stringByAppendingString:@" "];
    cell.senderLabel.text = [name stringByAppendingString:user.lastName];
    
    
    cell.lastChilTitleLabel.text = user.phoneNumber;
    
//    UIView *swipeView = [[UIView alloc] initWithFrame:cell.bounds];
//    swipeView.backgroundColor = [UIColor chillMintColor];
//
//    @weakify(self)
//    [cell setSwipeGestureWithView:swipeView
//                            color:swipeView.backgroundColor
//                             mode:MCSwipeTableViewCellModeExit
//                            state:MCSwipeTableViewCellState1
//                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
//
//        @strongify(self)
//        [self performSegueWithIdentifier:NSStringFromClass([CHLShareViewController class]) sender:cell];
//        [cell swipeToOriginWithCompletion:nil];
//
//    }];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHLAddressBookUserInfo *userInfo = self.users[indexPath.row];
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
        messageViewController.recipients = @[userInfo.phoneNumber];
        messageViewController.messageComposeDelegate = self;
        messageViewController.body = @"✌️ 😉 😆 👇\n Get a beta invite here\n http://iamchill.co";
        [self presentViewController:messageViewController animated:YES completion:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                       message:@"Sorry, messages are not available on your device"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {}];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Invite from address book screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Contact from address book tapped"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

#pragma mark - Message view controller delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSStringFromClass([CHLShareViewController class])]) {
        CHLShareViewController *shareViewController = segue.destinationViewController;
        shareViewController.isNonChillUser = YES;
    }
}

@end
