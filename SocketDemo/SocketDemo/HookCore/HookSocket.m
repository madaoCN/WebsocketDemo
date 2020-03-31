//
//  HookSocket.m
//  SocketDemo
//
//  Created by 梁宪松 on 2020/3/25.
//  Copyright © 2020 madao. All rights reserved.
//

#import "HookSocket.h"
#import "fishhook.h"
#import <CFNetwork/CFNetwork.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <objc/runtime.h>
#import "Aspects.h"

@implementation HookSocket

// connection
static int    (*orig_connect)(int, const struct sockaddr *, socklen_t);
int    hook_connect(int socket, const struct sockaddr *addr, socklen_t address_len) {
    char ipString[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &(((struct sockaddr_in*)addr)->sin_addr), ipString, INET_ADDRSTRLEN);
    NSLog(@"ip:%s", ipString);
    return orig_connect(socket, addr, address_len);
}

// send
static ssize_t    (*orig_send)(int, const void *, size_t, int);
ssize_t    hook_send(int socket, const void * buffer, size_t length, int flags) {
    NSLog(@"send:%s", buffer);
    return orig_send(socket, buffer, length, flags);
}

// receive
static ssize_t (*origin_recv)(int, void *, size_t, int);
ssize_t hook_recv(int socket, void *buffer, size_t length, int flags)
{
    NSLog(@"recevie:%s", buffer);
    return origin_recv(socket, buffer, length, flags);
}

+ (void)load
{
    struct rebinding socket_rebinding = {"connect", hook_connect, (void *)&orig_connect };
    struct rebinding send_rebinding = {"send", hook_send, (void *)&orig_send };
    struct rebinding recv_rebinding = {"recv", hook_recv, (void *)&origin_recv };
    rebind_symbols((struct rebinding[3]){socket_rebinding, send_rebinding, recv_rebinding}, 3);
    
    /*
     Printing description of readStream:
     <__NSCFInputStream: 0x600002f6a5b0>
     Printing description of writeStream:
     <__NSCFOutputStream: 0x600002f68a20>
     */

    // hook
    Class inputClzss = NSClassFromString(@"__NSCFInputStream");
    [inputClzss aspect_hookSelector:@selector(read:maxLength:) withOptions:(AspectPositionAfter) usingBlock:^(id<AspectInfo> aspectInfo, uint8_t *buffer, NSUInteger maxLength) {

        NSInputStream *instance = (NSInputStream *)[aspectInfo instance];
                NSString *hostName = [instance propertyForKey:(NSString *)kCFStreamPropertySocketRemoteHostName];
        NSString *portNum = [instance propertyForKey:(NSString *)kCFStreamPropertySocketRemotePortNumber];
        
        NSLog(@"===== ip: %@:%@ input: %s maxLength: %lu", hostName, portNum, buffer, (unsigned long)maxLength);
        ;
    } error:NULL];

    Class outputClzss = NSClassFromString(@"__NSCFOutputStream");
    [outputClzss aspect_hookSelector:@selector(write:maxLength:) withOptions:(AspectPositionAfter) usingBlock:^(id<AspectInfo> aspectInfo, const uint8_t *buffer, NSUInteger maxLength) {

        NSOutputStream *instance = (NSOutputStream *)[aspectInfo instance];
        NSString *hostName = [instance propertyForKey:(NSString *)kCFStreamPropertySocketRemoteHostName];
        NSString *portNum = [instance propertyForKey:(NSString *)kCFStreamPropertySocketRemotePortNumber];
        
        NSLog(@"===== ip: %@:%@ output: %s maxLength %lu", hostName, portNum, buffer, (unsigned long)maxLength);
        ;
    } error:NULL];
}

@end
