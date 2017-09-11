//
//  MyTextField.m
//  NetworkingTesting
//
//  Created by Hugh Bellamy on 20/09/2014.
//
//

#import "KeyboardTextField.h"

@implementation KeyboardTextField

- (void)setExtendedDelegate:(id<KeyboardTextFieldDelegate>)extendedDelegate {
    if(extendedDelegate) {
        [self addTarget:_extendedDelegate action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    }
    else if(_extendedDelegate) {
        [self removeTarget:_extendedDelegate action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    }
    _extendedDelegate = extendedDelegate;
}

- (void)setupToolbar {
    
    self.ctrlButton = [RFToolbarButton buttonWithTitle:@"Ctrl"];
    self.ctrlButton.tag = 0;
    
    self.fnButton = [RFToolbarButton buttonWithTitle:@"Fn"];
    self.fnButton.tag = 1;
    
    self.winButton = [RFToolbarButton buttonWithTitle:@"Win"];
    self.winButton.tag = 2;
    
    self.altButton = [RFToolbarButton buttonWithTitle:@"Alt"];
    self.altButton.tag = 3;
    
    self.delButton = [RFToolbarButton buttonWithTitle:@"Del"];
    self.delButton.tag = 4;

    self.tabButton = [RFToolbarButton buttonWithTitle:@"Tab"];
    self.tabButton.tag = 6;
    
    self.closeButton = [RFToolbarButton buttonWithTitle:@"X"];
    self.closeButton.tag = 5;
    
    __typeof__(self) __weak wself = self;
    [self.ctrlButton addEventHandler:^{
        [wself modifierKeyPressed:wself.ctrlButton];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.fnButton addEventHandler:^{
        [wself modifierKeyPressed:wself.fnButton];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.winButton addEventHandler:^{
        wself.text = @"wn";
        if([wself.extendedDelegate respondsToSelector:@selector(textFieldDidChangeText:)]) {
            [wself.extendedDelegate textFieldDidChangeText:wself];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.altButton addEventHandler:^{
        [wself modifierKeyPressed:wself.altButton];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.delButton addEventHandler:^{
        wself.text = @"dl";
        if([wself.extendedDelegate respondsToSelector:@selector(textFieldDidChangeText:)]) {
            [wself.extendedDelegate textFieldDidChangeText:wself];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabButton addEventHandler:^{
        wself.text = @"tb";
        if([wself.extendedDelegate respondsToSelector:@selector(textFieldDidChangeText:)]) {
            [wself.extendedDelegate textFieldDidChangeText:wself];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.closeButton addEventHandler:^{
        [wself resignFirstResponder:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    self.keyboardToolbar = [RFKeyboardToolbar toolbarViewWithButtons:@[self.ctrlButton, self.fnButton, self.winButton, self.altButton, self.delButton, self.tabButton/*[RFToolbarButton spaceButton], [RFToolbarButton spaceButton]*/, self.closeButton]];
    self.inputAccessoryView = self.keyboardToolbar;
}

- (void)deleteBackward {
    BOOL shouldDismiss = [self.text length] == 0;
    
    [super deleteBackward];
    
    if (shouldDismiss) {
        if ([_extendedDelegate respondsToSelector:@selector(textFieldDidDelete:)]) {
            [_extendedDelegate textFieldDidDelete:self];
        }
    }
}

- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    if (![textField.text length] && [[[UIDevice currentDevice] systemVersion] floatValue] >= 8 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.3) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}

- (BOOL)resignFirstResponder:(BOOL)delegate; {
    if(self.isFirstResponder && delegate && [_extendedDelegate respondsToSelector:@selector(textFieldDidResign:)]) {
        [_extendedDelegate textFieldDidResign:self];
    }
    return [super resignFirstResponder];
}

- (IBAction)close:(id)sender {
    [self resignFirstResponder:YES];
}

- (void)modifierKeyPressed:(RFToolbarButton*)button {
    [button toggleSelected];
    
    if([_extendedDelegate respondsToSelector:@selector(textField:didToggleModifierKey:)]) {
        [_extendedDelegate textField:self didToggleModifierKey:button.tag];
    }
}

- (IBAction)deleteKeyPressed:(UIBarButtonItem *)sender {
    self.text = @"dl";
    if([_extendedDelegate respondsToSelector:@selector(textFieldDidChangeText:)]) {
        [_extendedDelegate textFieldDidChangeText:self];
    }
}
- (IBAction)winKeyPressed:(id)sender {
    self.text = @"wn";
    if([_extendedDelegate respondsToSelector:@selector(textFieldDidChangeText:)]) {
        [_extendedDelegate textFieldDidChangeText:self];
    }
}

@end
