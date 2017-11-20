//
//  ZFTokenField.m
//  ZFTokenField
//
//  Created by Amornchai Kanokpullwad on 10/11/2014.
//  Copyright (c) 2014 Amornchai Kanokpullwad. All rights reserved.
//

#import "ZFTokenField.h"

@interface ZFTokenTextField ()
- (NSString *)rawText;
@end

@implementation ZFTokenTextField

- (void)setText:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        if (((ZFTokenField *)self.superview).numberOfToken > 0) {
            text = @"\u200B";
        }
    }
    [super setText:text];
}

- (NSString *)text
{
    return [super.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
}

- (NSString *)rawText
{
    return super.text;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent zooming
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}

@end

@interface ZFTokenField () <UITextFieldDelegate>
@property (nonatomic, strong) ZFTokenTextField *textField;
@property (nonatomic, strong) NSMutableArray *tokenViews;

@property (nonatomic, strong) NSString *tempTextFieldText;
@end

@implementation ZFTokenField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (BOOL)focusOnTextField
{
    [self.textField becomeFirstResponder];
    return YES;
}

#pragma mark -

- (void)setup
{
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(focusOnTextField) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField = [[ZFTokenTextField alloc] init];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.delegate = self;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.textField.textColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
    CGFloat size = [[UIScreen mainScreen] bounds].size.height * (14.0/ 568);
    self.textField.font = [UIFont fontWithName:@"HelveticaNeue" size:size];
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.placeholder = @"Enter other category";
    self.textField.layer.borderWidth = 1.0;
    self.textField.layer.borderColor = [[UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0] CGColor];
    self.textField.layer.cornerRadius = 2.0;
    self.textField.clipsToBounds = YES;
    self.textField.returnKeyType = UIReturnKeyDone;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self invalidateIntrinsicContentSize];
    
    NSEnumerator *tokenEnumerator = [self.tokenViews objectEnumerator];
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        UIView *token = [tokenEnumerator nextObject];
        [token setFrame:itemRect];
    }];
    
}

- (CGSize)intrinsicContentSize
{
    if (!self.tokenViews) {
        return CGSizeZero;
    }
    
    __block CGRect totalRect = CGRectNull;
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        totalRect = CGRectUnion(itemRect, totalRect);
    }];
    return totalRect.size;
}

#pragma mark - Public

- (void)reloadData
{
    // clear
    for (UIView *view in self.tokenViews) {
        [view removeFromSuperview];
    }
    self.tokenViews = [NSMutableArray array];
    
    if (self.dataSource) {
        NSUInteger count = [self.dataSource numberOfTokenInField:self];
        for (int i = 0 ; i < count ; i++) {
            UIView *tokenView = [self.dataSource tokenField:self viewForTokenAtIndex:i];
            tokenView.autoresizingMask = UIViewAutoresizingNone;
            [self addSubview:tokenView];
            [self.tokenViews addObject:tokenView];
        }
    }
    
    [self.tokenViews addObject:self.textField];
    self.textField.frame = (CGRect) {0, 0, 300, [self.dataSource lineHeightForTokenInField:self]};
    //self.textField.hidden = YES;
    [self addSubview:self.textField];
    
    [self invalidateIntrinsicContentSize];
   // [self.textField setText:nil];
}

- (NSUInteger)numberOfToken
{
    return self.tokenViews.count - 1;
}

- (NSUInteger)indexOfTokenView:(UIView *)view
{
    return [self.tokenViews indexOfObject:view];
}

- (UIView *)viewForIndex:(NSUInteger )index
{
    return [self.tokenViews objectAtIndex:index];
}
#pragma mark - Private

- (void)enumerateItemRectsUsingBlock:(void (^)(CGRect itemRect))block
{
    NSUInteger rowCount = 0;
    CGFloat x = 0, y = 0;
    CGFloat margin = 0;
    CGFloat lineHeight = [self.dataSource lineHeightForTokenInField:self];
    
    if ([self.delegate respondsToSelector:@selector(tokenMarginInTokenInField:)]) {
        margin = [self.delegate tokenMarginInTokenInField:self];
    }
    
    for (UIView *token in self.tokenViews) {
        CGFloat width = MAX(CGRectGetWidth(self.bounds), CGRectGetWidth(token.frame));
        CGFloat tokenWidth = MIN(CGRectGetWidth(self.bounds), CGRectGetWidth(token.frame));
        if (x > width - tokenWidth) {
            y += lineHeight + margin;
            x = 0;
            rowCount = 0;
        }
        
        if ([token isKindOfClass:[ZFTokenTextField class]]) {
            UITextField *textField = (UITextField *)token;
            CGSize size = [textField sizeThatFits:(CGSize){CGRectGetWidth(self.bounds), lineHeight}];
            size.height = lineHeight;
            if (size.width > CGRectGetWidth(self.bounds)) {
                size.width = CGRectGetWidth(self.bounds);
            }
            token.frame = (CGRect){{x, y}, size};
        }
        
        block((CGRect){x, y, tokenWidth, token.frame.size.height});
        x += tokenWidth + margin;
        rowCount++;
    }
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(ZFTokenTextField *)textField
{
    if([self.textField isHidden] == false)
    {
        self.tempTextFieldText = [textField rawText];
        
        if ([self.delegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]) {
            [self.delegate tokenFieldDidBeginEditing:self];
        }
    }
    else
    {
        [textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldEndEditing:(ZFTokenTextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenFieldShouldEndEditing:)]) {
        return [self.delegate tokenFieldShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(ZFTokenTextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)]) {
        [self.delegate tokenFieldDidEndEditing:self];
    }
}

- (void)textFieldDidChange:(ZFTokenTextField *)textField
{
    //    if ([[textField rawText] isEqualToString:@""]) {
    //        textField.text = @"\u200B";
    //
    //        if ([self.tempTextFieldText isEqualToString:@"\u200B"]) {
    //            if (self.tokenViews.count > 1) {
    //                NSUInteger removeIndex = self.tokenViews.count - 2;
    //                [self.tokenViews[removeIndex] removeFromSuperview];
    //                [self.tokenViews removeObjectAtIndex:removeIndex];
    //
    //                [self.textField setText:@""];
    //
    //                if ([self.delegate respondsToSelector:@selector(tokenField:didRemoveTokenAtIndex:)]) {
    //                    [self.delegate tokenField:self didRemoveTokenAtIndex:removeIndex];
    //                }
    //            }
    //        }
    //    }
    //
    //    self.tempTextFieldText = [textField rawText];
    //    [self invalidateIntrinsicContentSize];
    //
    //    if ([self.delegate respondsToSelector:@selector(tokenField:didTextChanged:)]) {
    //        [self.delegate tokenField:self didTextChanged:textField.text];
    //    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   // [textField resignFirstResponder];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"viewDown"
     object:self];
    
    if(textField.text.length > 0)
    {
        if ([self.delegate respondsToSelector:@selector(tokenField:didReturnWithText:)]) {
            [self.delegate tokenField:self didReturnWithText:textField.text];
        }
        return YES;
    }
    else
    {
        //textField.hidden = YES;
        return  NO;
    }
}


@end
