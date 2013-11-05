//
//  EBViewController.m
//  eyebrowse
//
//  Created by Justin R. Miller on 11/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "EBViewController.h"

@interface EBViewController () <UITextFieldDelegate, UIScrollViewAccessibilityDelegate, UIWebViewDelegate>

@property UIWebView *webView;
@property UITextField *addressField;
@property UIWindow *externalWindow;
@property UIScrollView *scrollView;

@end

@implementation EBViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.view.backgroundColor = [UIColor lightGrayColor];

    UITextField *infoField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
    infoField.textAlignment = NSTextAlignmentCenter;
    infoField.text = @"Press the Play button to swap displays. Pan here to scroll.";
    infoField.center = self.view.center;
    [self.view addSubview:infoField];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://github.com/incanus/eyebrowse"]]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenConnect:)    name:UIScreenDidConnectNotification    object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDisconnect:) name:UIScreenDidDisconnectNotification object:nil];

    if ([[UIScreen screens] count] > 1 && [[[UIScreen screens] objectAtIndex:1] mirroredScreen])
    {
        [self screenConnect:nil];
    }
}

- (void)updateToolbar
{
    UIToolbar *toolbar = (UIToolbar *)self.navigationItem.titleView;

    if ( ! toolbar)
    {
        NSMutableArray *toolbarItems = [NSMutableArray array];

        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self.webView action:@selector(goBack)];
        backButton.enabled = self.webView.canGoBack;
        [toolbarItems addObject:backButton];

        UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
        reloadButton.enabled = ! self.webView.isLoading;
        [toolbarItems addObject:reloadButton];

        UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)];
        stopButton.enabled = self.webView.isLoading;
        [toolbarItems addObject:stopButton];

        NSString *address = self.addressField.text;
        self.addressField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 850, self.navigationController.navigationBar.bounds.size.height - 10)];
        self.addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.addressField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.addressField.borderStyle = UITextBorderStyleRoundedRect;
        self.addressField.delegate = self;
        self.addressField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.addressField.keyboardType = UIKeyboardTypeURL;
        self.addressField.returnKeyType = UIReturnKeyGo;
        self.addressField.text = address;
        [toolbarItems addObject:[[UIBarButtonItem alloc] initWithCustomView:self.addressField]];

        UIBarButtonItem *swapButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(swapExternal:)];
        swapButton.enabled = (self.externalWindow != nil);
        [toolbarItems addObject:swapButton];

        toolbar = [[UIToolbar alloc] initWithFrame:self.navigationController.navigationBar.bounds];
        toolbar.items = toolbarItems;

        self.navigationItem.titleView = toolbar;
    }

    ((UIBarButtonItem *)toolbar.items[0]).enabled = self.webView.canGoBack;
    ((UIBarButtonItem *)toolbar.items[1]).enabled = ! self.webView.isLoading;
    ((UIBarButtonItem *)toolbar.items[2]).enabled = self.webView.isLoading;
    ((UIBarButtonItem *)toolbar.items[4]).enabled = (self.externalWindow != nil);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.webView.scrollView.contentOffset = scrollView.contentOffset;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.addressField.text = [webView.request.URL absoluteString];

    [self updateToolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.addressField.text = [[[webView.request.URL absoluteString] stringByAppendingString:@" - "] stringByAppendingString:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];

    self.scrollView.contentSize = CGSizeMake(1, self.webView.scrollView.contentSize.height);

    [self updateToolbar];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.addressField.text = @"Error loading URL";

    [self updateToolbar];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = [self.webView.request.URL absoluteString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if ( ! [textField.text hasPrefix:@"http"])
        textField.text = [@"http://" stringByAppendingString:textField.text];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:textField.text]]];

    return YES;
}

- (void)swapExternal:(id)sender
{
    if ([self.webView.superview isEqual:self.view])
    {
        [self.webView removeFromSuperview];
        self.webView.frame = self.externalWindow.bounds;
        [self.externalWindow addSubview:self.webView];
    }
    else
    {
        [self.webView removeFromSuperview];
        self.webView.frame = self.view.bounds;
        [self.view addSubview:self.webView];
    }
}

- (void)screenConnect:(NSNotification *)notification
{
    UIScreen *externalScreen = [UIScreen screens][1];
    self.externalWindow = [[UIWindow alloc] initWithFrame:externalScreen.bounds];
    self.externalWindow.screen = externalScreen;
    self.externalWindow.backgroundColor = [UIColor lightGrayColor];
    UITextField *infoField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    infoField.textAlignment = NSTextAlignmentCenter;
    infoField.text = @"Press the Play button to swap displays";
    infoField.center = self.externalWindow.center;
    [self.externalWindow addSubview:infoField];
    [self.externalWindow makeKeyAndVisible];

    [self updateToolbar];
}

- (void)screenDisconnect:(NSNotification *)notification
{
    if ([self.webView.superview isEqual:self.externalWindow])
    {
        [self swapExternal:self];
    }

    [self.externalWindow removeFromSuperview];
    self.externalWindow = nil;

    [self updateToolbar];
}

@end
