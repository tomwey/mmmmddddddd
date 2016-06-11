//  DMS.h
//  MQTTKit

#import "MQTTKit.h"

#define DMS_DEFAULT_QOS         AtLeastOnce
#define DMS_DEFAULT_RETAIN      NO
#define DMS_DEFAULT_KEEPALIVE   40
#define DMS_DEFAULT_RETRY       60
#define DMS_SUCCESS             0

@interface DMS : NSObject

@property (readonly,nonatomic, strong) MQTTClient *client;

+(instancetype)dmsWithClientId: (NSString *)clientId;
- (instancetype) initWithClientId: (NSString *)clientId;
- (BOOL) connectToHost: (NSString*)host
        withPubKey:(NSString *) pubKey
        subKey:(NSString *) subkey
        completionHandler:(void (^)(MQTTConnectionReturnCode code))completionHandler;
- (void)subscribe:(NSString *)topic
        withCompletionHandler:(MQTTSubscriptionCompletionHandler)completionHandler;
- (void)publishData:(NSData *)payload
            toTopic:(NSString *)topic
        completionHandler:(void (^)(int mid))completionHandler;
- (void)publishString:(NSString *)payload
              toTopic:(NSString *)topic
        completionHandler:(void (^)(int mid))completionHandler;
- (void)unsubscribe: (NSString *)topic
        withCompletionHandler:(void (^)(void))completionHandler;
- (void) disconnectWithCompletionHandler:(MQTTDisconnectionHandler)completionHandler;
- (void) setMessageHandler:(MQTTMessageHandler) handler;
- (void) setDisconnectionHandler:(MQTTDisconnectionHandler) handler;
- (void) close;
@end