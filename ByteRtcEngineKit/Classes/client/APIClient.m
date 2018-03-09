//
//  APIClient.m
//  RtcSDK
//
//  Created by gaosiyu on 2018/2/28.
//  Copyright © 2018年 gaosiyu. All rights reserved.
//

#import "APIClient.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation APIClient
- (BOOL)in:(NSString * _Nullable)roomName {
    return NO;
}
- (instancetype _Nonnull)init:(NSString * _Nullable)nuveIP nuvePort:(NSInteger)nuvePort secure:(BOOL)secure roomName:(NSString * _Nullable)roomName userName:(NSString * _Nullable)userName role:(NSString * _Nullable) role appid:(NSString * _Nullable) appid appkey:(NSString * _Nullable) appkey delegate:(id<ByteRtcEngineDelegate> _Nullable)delegate {
    self.nuveIP = nuveIP;
    self.nuvePort = nuvePort;
    self.secure = secure;
    self.roomName = roomName;
    self.username = userName;
    self.role = role;
    self.appid = appid;
    self.appkey = appkey;
    self.globalDelegate = delegate;
    return self;
}
- (BOOL)getRoom {
    NSString *endpoint = @"/rooms";
    NSString *authorizationHeader = [self generateAuthHeader];
    NSString *response = [self performRequest:endpoint method:@"GET" postData:nil authorization:authorizationHeader];
    if(response != nil) {
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSArray * rooms = [self parseResponse:data];
        if(rooms != nil) {
            for (NSDictionary *room in rooms) {
                NSString *name =  [room objectForKey:@"name"];
                if([name compare:self.roomName] == NSOrderedSame) {
                    self.roomid = [room objectForKey:@"_id"];
                    return YES;
                }
            }
        }
    }
    return NO;
}
- (BOOL)createRoom {
    NSString *endpoint = @"/rooms";
    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithObject:self.roomName forKey:@"name"];
    [postData setValue:@"erizo" forKey:@"type"];
    [postData setValue:@"default" forKey:@"mediaConfiguration"];
    NSString *authorizationHeader = [self generateAuthHeader];

    NSString *response = [self performRequest:endpoint method:@"POST" postData:postData authorization:authorizationHeader];
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObject = [self parseResponse:data];
    if(jsonObject != nil) {
        self.roomid = [jsonObject valueForKey:@"_id"];
        return YES;
    }
    return NO;
}
- (BOOL)createToken {
    NSString *endpoint = [NSString stringWithFormat:@"/rooms/%@/tokens", self.roomid];
    NSString *authorizationHeader = [self generateAuthHeader];
    NSString *response = [self performRequest:endpoint method:@"POST" postData:nil authorization:authorizationHeader];
    //NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    //NSDictionary *jsonObject = [self parseResponse:data];
    if(response != nil) {
        self.token = response;
        return YES;
    }
    return NO;
}
- (NSString * _Nullable)getToken {
    return self.token;
}
- (id)parseResponse:(NSData *)data {
    if (!data)
        return nil;
    NSString *parsedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *firstCharacter = [parsedData substringWithRange:NSMakeRange(0, 1)];
    if ([firstCharacter isEqualToString:@"{"] || [firstCharacter isEqualToString:@"["]) {
        NSData *jsonData = [parsedData dataUsingEncoding:NSUnicodeStringEncoding];
        NSError *error;
        if (!error) {
            return [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        } else {
            return nil;
        }
    } else {
        return parsedData;
    }
}
- (NSString * _Nullable)performRequest:(NSString * _Nullable)path
                                method:(NSString * _Nullable)method
                              postData:(NSDictionary * _Nullable)postData
                         authorization:(NSString * _Nullable)authorization {
    NSString *kNuveHost = [NSString stringWithFormat:@"http://%@:%d",self.nuveIP,(int)self.nuvePort];
    NSURL *url = [NSURL URLWithString:[kNuveHost stringByAppendingString:path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if ([postData count] > 0) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSData * data = [NSJSONSerialization dataWithJSONObject:postData
                                                        options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = data;
    }
    
    request.HTTPMethod = method;
    
    [request addValue:authorization forHTTPHeaderField:@"Authorization"];
    
    /*NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    if (!error && httpResponse.statusCode >= 200 && httpResponse.statusCode <= 400) {
                        completion(YES, [self parseResponse:data]);
                    } else {
                        completion(NO, [self parseResponse:data]);
                    }
                }] resume];*/
    NSError *err;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    if(err == nil) {
        return [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    }
    return nil;
}
- (NSString * _Nullable)generateAuthHeader {
    NSString *mAuth = @"MAuth realm=http://marte3.dit.upm.es,mauth_signature_method=HMAC_SHA1";
    
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *cNounce = [NSNumber numberWithInt:arc4random_uniform(99999)];
    
    
    NSString *timestampStr = [NSString stringWithFormat:@"%lu", (long)timestamp];
    NSString *cNounceStr = [NSString stringWithFormat:@"%@", cNounce];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@,%@",
                              timestampStr, cNounceStr];
    
    NSString *userAndRole = [NSString stringWithFormat:@",%@,%@", self.username, self.role];
    stringToSign = [stringToSign stringByAppendingString:userAndRole];
    
    
    NSString *signature = [self hmacsha1:stringToSign];
    
    NSString *authorizationHeaderValue;
    
    authorizationHeaderValue = [NSString stringWithFormat:@"%@,mauth_username=%@,mauth_role=%@,mauth_serviceid=%@,mauth_cnonce=%@,mauth_timestamp=%@,mauth_signature=%@", mAuth, self.username, self.role, self.appid, cNounce, timestampStr, signature];

    return authorizationHeaderValue;
}
- (NSString * _Nullable)hmacsha1:(NSString * _Nullable)text {
    NSData *keyData = [self.appkey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *hMacOut = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length], [textData bytes], [textData length], hMacOut.mutableBytes);
    
    NSString *hexString = @"";
    uint8_t *dataPointer = (uint8_t *)(hMacOut.bytes);
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        hexString = [hexString stringByAppendingFormat:@"%02x", dataPointer[i]];
    }
    
    NSString *base64EncodedResult = [[hexString dataUsingEncoding:NSUTF8StringEncoding]
                                     base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return base64EncodedResult;
}
@end
