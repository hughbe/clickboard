//
//  ClickBoardServer.h
//  test
//
//  Created by Hugh Bellamy on 27/09/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClickBoardConstants.h"
@protocol ClickBoardServerDelegate;
@protocol ClickBoardServerDataStream;

typedef NS_ENUM(NSInteger, ServerErrorCode) {
    kServerCouldNotBindToIPv4Address,
    kServerCouldNotBindToIPv6Address,
    kServerNoSocketsAvailable,
    kServerCouldNotPublish,
    kServerNoSpaceOnOutputStream,
    kServerOutputStreamReachedCapacity
} ;

@interface ClickBoardServer : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, NSStreamDelegate>

- (void)sendString:(NSString *)string;
- (void)sendData:(NSData *)data;

- (void)stop;
- (void)stopBrowser;

- (instancetype)initWithProtocol:(NSString *)type delegate:(id<ClickBoardServerDelegate>)delegate;
- (instancetype)initWithProtocol:(NSString *)type domain:(NSString*)domain  delegate:(id<ClickBoardServerDelegate>)delegate;

@property (strong, nonatomic, readonly) NSString *type;
@property (strong, nonatomic, readonly) NSString *domain;

@property (strong, nonatomic, readonly) NSMutableArray *services;
@property (strong, nonatomic, readonly) NSNetService *resolvedService;

@property (weak, nonatomic) id<ClickBoardServerDelegate> delegate;
@property (weak, nonatomic) id<ClickBoardServerDataStream> dataStreamDelegate;

- (void)searchForServicesOfType:(NSString *)type;
- (void)resolveNetService:(NSNetService*)service;
- (void)resolveNetService:(NSNetService*)service withTimeout:(NSTimeInterval)timeout;
- (void)connectToAddress:(const char *)address port:(int)port service:(NSNetService *)service;

@property(nonatomic, strong) NSInputStream *inputStream;
@property(nonatomic, strong) NSOutputStream *outputStream;
@end

@protocol ClickBoardServerDelegate <NSObject>

- (void)clickBoardServer:(ClickBoardServer *)server didNotStart:(NSDictionary *)errorDict;

- (void)clickBoardServer:(ClickBoardServer *)server didCompleteRemoteConnectionWithService:(NSNetService*)service;
- (void)clickBoardServer:(ClickBoardServer *)server lostConnection:(NSDictionary *)errorDict;

- (void)clickBoardServer:(ClickBoardServer*)server didFindServices:(NSArray *)services;

- (void)clickBoardServer:(ClickBoardServer *)server didConnectToPCType:(PCType)type;

@optional


@end

@protocol ClickBoardServerDataStream <NSObject>

@optional
- (void)clickBoardServer:(ClickBoardServer *)server didAcceptData:(NSData *)data;
- (void)clickBoardServer:(ClickBoardServer *)server didAcceptString:(NSString *)string;

@end;
