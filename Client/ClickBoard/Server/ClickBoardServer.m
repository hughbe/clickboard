//
//  ClickBoardServer.m
//  test
//
//  Created by Hugh Bellamy on 27/09/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import "ClickBoardServer.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <UIKit/UIKit.h>

NSString * const ServerErrorDomain = @"ServerErrorDomain";
static NSString * DeviceName();

@interface ClickBoardServer()

@property (strong, nonatomic) NSNetServiceBrowser *browser;


@property (strong, nonatomic, readwrite) NSMutableArray *services;
@property (strong, nonatomic, readwrite) NSNetService *resolvedService;

@property (strong, nonatomic, readwrite) NSString *type;
@property (strong, nonatomic, readwrite) NSString *domain;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) uint16_t port;
@property(nonatomic, assign) CFSocketRef socket;

@end

@implementation ClickBoardServer

- (instancetype)initWithProtocol:(NSString *)type domain:(NSString*)domain delegate:(id<ClickBoardServerDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        self.services = [NSMutableArray array];
        self.type = type;
        self.domain = domain;
        self.name = @"";

        
        self.browser = [[NSNetServiceBrowser alloc]init];
        self.browser.delegate = self;
    }
    return self;
}

- (instancetype)initWithProtocol:(NSString *)type delegate:(id<ClickBoardServerDelegate>)delegate {
    return [self initWithProtocol:type domain:@"" delegate:delegate];
}

- (void)sendString:(NSString *)string {
    [self sendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendData:(NSData *)data {
    if(self.outputStream.hasSpaceAvailable) {
        [self.outputStream write:[data bytes] maxLength:[data length]];
    }
}

#pragma mark NSNetServiceBrowser methods

- (void)stopBrowser {
    [self.browser stop];
    self.browser.delegate = nil;
    self.browser = nil;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.services addObject:aNetService];
    if(!moreComing && [self.delegate respondsToSelector:@selector(clickBoardServer:didFindServices:)]) {
        [self.delegate clickBoardServer:self didFindServices:[self.services copy]];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
    [self.services removeObject:service];
    
    if(!moreComing && [self.delegate respondsToSelector:@selector(clickBoardServer:didFindServices:)]) {
        [self.delegate clickBoardServer:self didFindServices:[self.services copy]];
    }
}

- (void)searchForServicesOfType:(NSString *)type {
    [self stopBrowser];
    
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.delegate = self;
    [self.browser searchForServicesOfType:type inDomain:@""];
}

- (void)resolveNetService:(NSNetService*)service {
    [self resolveNetService:service withTimeout:0];
}

- (void)resolveNetService:(NSNetService*)service withTimeout:(NSTimeInterval)timeout {
    service.delegate = self;
    [service resolveWithTimeout:timeout];
}

#pragma mark NSNetService methods

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    //Get IPV6 address
    char addressBuffer[INET6_ADDRSTRLEN];
    
    for (NSData *data in service.addresses)
    {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);
        
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;
        
        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
        
        if (socketAddress && (socketAddress->sa.sa_family == AF_INET))// || socketAddress->sa.sa_family == AF_INET6))
        {
            const char *addressStr = inet_ntop(socketAddress->sa.sa_family,
                                              (void *)&(socketAddress->ipv4.sin_addr),
                                               addressBuffer,
                                               sizeof(addressBuffer));
            
            int port = ntohs(socketAddress->ipv4.sin_port);
            
            if (addressStr && port)
            {
                //NSLog(@"Found service at %s:%d", addressStr, port) clickBoardServer:self didCompleteRemoteConnectionWithService:service];
                [self connectToAddress:addressStr port:port service:service];
                break;
            }
        }
    }
}

- (void)connectToAddress:(const char *)address port:(int)port service:(NSNetService *)service {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)@(address), port, &readStream, &writeStream);
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //x[self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.inputStream open];
    [self.outputStream open];
    
    self.resolvedService = service;
    if([self.delegate respondsToSelector:@selector(clickBoardServer:didCompleteRemoteConnectionWithService:)]) {
        [self.delegate clickBoardServer:self didCompleteRemoteConnectionWithService:service];
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSAssert([self.delegate respondsToSelector:@selector(clickBoardServer:didNotStart:)], @"Implement the clickBoardServer:didNotStart: delegate method");
    [self.delegate clickBoardServer:self didNotStart:errorDict];
}

- (void)stopStreams {
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream = nil;
    self.inputStream.delegate = nil;
    
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.outputStream = nil;
    self.outputStream.delegate = nil;
}

//Stop server, turn off netService, close socket, stop streams, inform delegate
- (void)stop {
    if(self.socket && CFSocketIsValid(self.socket)) {
        CFSocketInvalidate(self.socket);
        self.socket = NULL;
    }
    [self stopStreams];
}

#pragma mark NSStream methods

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            //NSLog(@"Stream opened");
            if(aStream == self.outputStream) {
                NSString *response  = [NSString stringWithFormat:@"iam:%@", DeviceName()];
                NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
                [self.outputStream write:[data bytes] maxLength:[data length]];
            }
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            if (aStream == self.inputStream) {
                uint8_t buffer[4096];
                long len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:4096];
                    
                }
                if (len > 0) {
                    
                    NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                    
                    if (output) {
                        if([output isEqualToString:@"0"]) {
                            [self.delegate clickBoardServer:self didConnectToPCType:PCTypeWindows];
                        }
                        else if([output isEqualToString:@"1"]) {
                            [self.delegate clickBoardServer:self didConnectToPCType:PCTypeMac];
                        }
                        
                        //NSLog(@"server said: %@", output);
                        if([output isKindOfClass:[NSString class]] && [self.dataStreamDelegate respondsToSelector:@selector(clickBoardServer:didAcceptString:)]) {
                            [self.dataStreamDelegate clickBoardServer:self didAcceptString:output];
                        }
                    }
                }
            }
            break;
        }
        case NSStreamEventErrorOccurred:
            if([self.delegate respondsToSelector:@selector(clickBoardServer:lostConnection:)]) {
                [self.delegate clickBoardServer:self lostConnection:[[aStream streamError] userInfo]];
            }
            @try {
                if(self) {
                    [self stop];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                
            }
            break;
            
        case NSStreamEventEndEncountered:
            if([self.delegate respondsToSelector:@selector(clickBoardServer:lostConnection:)]) {
                [self.delegate clickBoardServer:self lostConnection:nil];
            }
            [self stop];
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    [self stop];
    [self stopBrowser];
    _delegate = nil;
    
}

@end

static NSString* DeviceName ()
{
    return [[UIDevice currentDevice] name];
}
