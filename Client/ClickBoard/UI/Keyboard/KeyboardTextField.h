//
//  MyTextField.h
//  NetworkingTesting
//
//  Created by Hugh Bellamy on 20/09/2014.
//
//

#import <UIKit/UIKit.h>
#import "RFKeyboardToolbar.h"
#import "RFToolbarButton.h"

@protocol KeyboardTextFieldDelegate;
typedef NS_ENUM(NSUInteger, KeyboardTextFieldModiferKey) {
    KeyboardTextFieldModiferKeyCtrl,
    KeyboardTextFieldModiferKeyFn,
    KeyboardTextFieldModiferKeyWin,
    KeyboardTextFieldModiferKeyAlt,
    KeyboardTextFieldModiferKeyDelete
};


@interface KeyboardTextField : UITextField <UIKeyInput, UITextFieldDelegate>

- (BOOL)resignFirstResponder:(BOOL)delegate;
- (void)setupToolbar;

@property (nonatomic, assign) id<KeyboardTextFieldDelegate> extendedDelegate;

@property (strong, nonatomic) RFToolbarButton *ctrlButton;
@property (strong, nonatomic) RFToolbarButton *fnButton;
@property (strong, nonatomic) RFToolbarButton *winButton;
@property (strong, nonatomic) RFToolbarButton *altButton;

@property (strong, nonatomic) RFToolbarButton *delButton;
@property (strong, nonatomic) RFToolbarButton *tabButton;
@property (strong, nonatomic) RFToolbarButton *closeButton;

@property (strong, nonatomic) RFKeyboardToolbar *keyboardToolbar;

@end

@protocol KeyboardTextFieldDelegate <NSObject>

@optional

- (void)textFieldDidChangeText:(KeyboardTextField *)textField;

- (void)textFieldDidDelete:(KeyboardTextField*)textField;
- (void)textFieldDidResign:(KeyboardTextField*)textField;

- (void)textField:(KeyboardTextField*)textField didToggleModifierKey:(KeyboardTextFieldModiferKey)key;

@end
