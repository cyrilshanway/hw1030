//
//  ViewController.m
//  hw1030
//
//  Created by Cyrilshanway on 2014/10/30.
//  Copyright (c) 2014年 Cyrilshanway. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property(nonatomic, strong)NSMutableData *responseData;
@end

@implementation ViewController
// parse -BookDU
#define kParseAppId @"BWSy3Rl4WBbnnFAxyJhIBSp7IsMwJHaGAQdDNjyZ"
#define kParseAPIKey  @"qqxER8K4WhA0Be9UfbUowdLToCjbxchqXyDBjEJ2"

// open data
// http://data.taipei.gov.tw/opendata/apply/NewDataContent;jsessionid=3A72E7293456D38F190F78FD2EBDC802?oid=683965F5-7E23-4134-ADB1-99C4FB1EA517
#define kOpenDataParkAPI  @"http://data.taipei.gov.tw/opendata/apply/json/NjgzOTY1RjUtN0UyMy00MTM0LUFEQjEtOTlDNEZCMUVBNTE3"
// delegate
// http://data.taipei.gov.tw/opendata/apply/NewDataContent;jsessionid=3A72E7293456D38F190F78FD2EBDC802?oid=68434B0E-5584-41A8-8BAD-969DEC4FFF1E
#define kOpenDataZooAPI  @"http://data.taipei.gov.tw/opendata/apply/json/Njg0MzRCMEUtNTU4NC00MUE4LThCQUQtOTY5REVDNEZGRjFF"

#define kUserAccount @""
#define kUserPassword  @"$"

#pragma MARK - 10/31(從storyboard寫，所以要用這方程式)
- (void)awakeFromNib {
    _responseData = [[NSMutableData alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
#pragma mark - parse url connect
- (IBAction)parseBtnPressed:(id)sender {
    // 宣告request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.parse.com/1/classes/Customer"]cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:60];//秒數
    // 轉成NSMutableRequest
    NSMutableURLRequest *mutableRequest =[request mutableCopy];
    //加值進NSMutableURLRequest
    [mutableRequest addValue:kParseAppId  forHTTPHeaderField:@"X-Parse-Application-Id"];
    [mutableRequest addValue:kParseAPIKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [mutableRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPMethod:@"GET"];
    //宣告NSURLCconnection sendAsynchronousRequest:
    [NSURLConnection sendAsynchronousRequest:mutableRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:&error];
            if (!error) {
                NSLog(@"jsonDictionary:%@", jsonDictionary);
            }else{
                NSLog(@"Error:%@",error);
            }
        }else{
            NSLog(@"connect error:%@", connectionError);
        }
    }];
}

#pragma amrk - open data url connect
- (IBAction)openDataBtnPressed:(id)sender {
    //宣告request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kOpenDataParkAPI] cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:60];
    //宣告NSURLCconnection sendAsynchronousRequest:
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                for (NSDictionary *eachPark in jsonArray) {
                    NSString *title = [eachPark objectForKey:@"stitle"];
                    NSString *body = [eachPark objectForKey:@"xbody"];
                    
                    NSLog(@"Park info: %@, %@", title, body);
                }
                
                
            } else {
                NSLog(@"Error with: %@", error);
            }
        } else {
            NSLog(@"Connection with: %@", connectionError);
        }
        
    }];

}

#pragma mark - delegate url connect
- (IBAction)useDelegateButtonpressed:(id)sender {
    // 宣告request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kOpenDataZooAPI]];
    //宣告connection alloc/init
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //從頭開始的意思？
    [self.responseData setLength:0];
    //開始連接
    [connection start];

}

#pragma mark - NSURLConnectionDelegate
// method is option:取前三組實現方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //是否連線成功
    }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return YES;
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:kUserAccount
                                                             password:kUserPassword persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate(DATA)
//method is option:取2.3.7組方法實現
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    // 宣告string(initWithdata)
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingMutableContainers) error:&error];
    NSLog(@"jsonDictionary connectionDidFinishLoading: %@", jsonDictionary);
}
@end
