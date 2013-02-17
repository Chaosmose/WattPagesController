//
//  WATTPageViewController.m
//  WattPagingContainer
//
//
//  Created by Benoit Pereira da Silva on 15/02/13.
//  Copyright (c) 2013 https://github.com/benoit-pereira-da-silva/
//  http://www.pereira-da-silva.com

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "WATTPageController.h"

@interface WATTPageController ()
@end

@implementation WATTPageController {
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
    WATTPageController* __weak weakSelf=self;
    [UIView animateWithDuration:0.5f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [weakSelf.webView setAlpha:0.8f];
                         [weakSelf.activityIndicator stopAnimating];
                         [weakSelf.activityIndicator setAlpha:0.f];
                     } completion:^(BOOL finished) {
                         
                     }];
}


#pragma mark - WATTPageProtocol


-(void)configureWithModel:(id)model{
    if([model isKindOfClass:[WATTPageModel class]]){
        WATTPageModel *castedModel=(WATTPageModel*)model;
        // we do configure the view according to the model;
        if(castedModel.url){
            BOOL urlHasChanged= (![castedModel.url.absoluteString isEqualToString:_currentRequest.URL.absoluteString]|| ! _currentRequest);
            if([self.webView isLoading] && urlHasChanged){
                [self.webView stopLoading];
                [self _prepareForLoading];
            }
            if(urlHasChanged){
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
    [self.webView setAlpha:0.5f];
    [self.webView.scrollView setBounces:NO]; // (!) 
    [self.activityIndicator setAlpha:1.f];
    [self.activityIndicator startAnimating];
}


@end
