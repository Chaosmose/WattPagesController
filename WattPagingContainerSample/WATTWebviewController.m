//
//  WATTPageViewController.m
//  WattPagingContainer
//
//
//  Created by Benoit Pereira da Silva on 15/02/13.
//  Copyright (c) 2013 https://github.com/benoit-pereira-da-silva/
//  http://www.pereira-da-silva.com

// This file is part of WattPagingContainer
//
// WattPagingContainer is free software: you can redistribute it and/or modify
// it under the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// WattPagingContainer is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU LESSER GENERAL PUBLIC LICENSE for more details.

// You should have received a copy of the GNU LESSER GENERAL PUBLIC LICENSE
// along with WattPagingContainer  If not, see <http://www.gnu.org/licenses/>


#import "WATTWebviewController.h"

@interface WATTWebviewController ()
@end

@implementation WATTWebviewController {
    NSURLRequest *_currentRequest;
}


#pragma mark - life cycle

-(void)viewDidLoad{
    [super viewDidLoad];
    [self _prepareForLoading];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if(![webView.request.URL.absoluteString isEqualToString:@"about:blank"]){
        
        WATTWebviewController* __weak weakSelf=self;
        [UIView animateWithDuration:0.5f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [weakSelf.webView setAlpha:1.0f];
                             [weakSelf.activityIndicator stopAnimating];
                             [weakSelf.activityIndicator setAlpha:0.f];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}


#pragma mark - WATTPageProtocol


-(void)configureWithModel:(id)model{
    if([model isKindOfClass:[WATTWebModel class]]){
        WATTWebModel *castedModel=(WATTWebModel*)model;
        // we do configure the view according to the model;
        if(castedModel.url){
            BOOL urlHasChanged= (![castedModel.url.absoluteString isEqualToString:_currentRequest.URL.absoluteString]|| ! _currentRequest);
            if(urlHasChanged){
                [self _prepareForLoading];
                _currentRequest=[NSURLRequest requestWithURL:castedModel.url];
                [self.webView setDelegate:self];
                [self.webView loadRequest:_currentRequest];
            }
        }
        
    }else{
        // We prefer to be strongly typed
        // So we accept only a specific model.
        [NSException raise:@"WATTPageProtocol Model inconsistency"
                    format:@"Model should be a WATTPageModel and is currently %@",NSStringFromClass([model class])];
    }
}

#pragma mark -

- (void)_prepareForLoading{
    [self.webView stopLoading];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    //[self.webView stringByEvaluatingJavaScriptFromString:@"document.innerHTML = '';"];
    [self.webView setAlpha:0.5f];
    [self.webView setScalesPageToFit:YES];
    [self.webView setClipsToBounds:YES];
    [self.webView.scrollView setBounces:NO]; // (!)
    [self.activityIndicator setAlpha:1.f];
    [self.activityIndicator startAnimating];
}


#pragma mark -
#pragma mark Debug facility


-(NSString*)description{
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass([self class]),_currentRequest.URL.absoluteString];
}




@end
