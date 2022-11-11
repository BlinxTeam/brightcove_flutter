// Autogenerated from Pigeon (v4.2.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import "BrightcoveIosPlugin.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString *, id> *wrapResult(id result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ?: [NSNull null]),
        @"message": (error.message ?: [NSNull null]),
        @"details": (error.details ?: [NSNull null]),
        };
  }
  return @{
      @"result": (result ?: [NSNull null]),
      @"error": errorDict,
      };
}
static id GetNullableObject(NSDictionary* dict, id key) {
  id result = dict[key];
  return (result == [NSNull null]) ? nil : result;
}
static id GetNullableObjectAtIndex(NSArray* array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}


@interface TextureMessage ()
+ (TextureMessage *)fromMap:(NSDictionary *)dict;
+ (nullable TextureMessage *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface VolumeMessage ()
+ (VolumeMessage *)fromMap:(NSDictionary *)dict;
+ (nullable VolumeMessage *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface PositionMessage ()
+ (PositionMessage *)fromMap:(NSDictionary *)dict;
+ (nullable PositionMessage *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface PlayMessage ()
+ (PlayMessage *)fromMap:(NSDictionary *)dict;
+ (nullable PlayMessage *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@implementation TextureMessage
+ (instancetype)makeWithPlayerId:(NSString *)playerId {
  TextureMessage* pigeonResult = [[TextureMessage alloc] init];
  pigeonResult.playerId = playerId;
  return pigeonResult;
}
+ (TextureMessage *)fromMap:(NSDictionary *)dict {
  TextureMessage *pigeonResult = [[TextureMessage alloc] init];
  pigeonResult.playerId = GetNullableObject(dict, @"playerId");
  NSAssert(pigeonResult.playerId != nil, @"");
  return pigeonResult;
}
+ (nullable TextureMessage *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [TextureMessage fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"playerId" : (self.playerId ?: [NSNull null]),
  };
}
@end

@implementation VolumeMessage
+ (instancetype)makeWithPlayerId:(NSString *)playerId
    volume:(NSNumber *)volume {
  VolumeMessage* pigeonResult = [[VolumeMessage alloc] init];
  pigeonResult.playerId = playerId;
  pigeonResult.volume = volume;
  return pigeonResult;
}
+ (VolumeMessage *)fromMap:(NSDictionary *)dict {
  VolumeMessage *pigeonResult = [[VolumeMessage alloc] init];
  pigeonResult.playerId = GetNullableObject(dict, @"playerId");
  NSAssert(pigeonResult.playerId != nil, @"");
  pigeonResult.volume = GetNullableObject(dict, @"volume");
  NSAssert(pigeonResult.volume != nil, @"");
  return pigeonResult;
}
+ (nullable VolumeMessage *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [VolumeMessage fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"playerId" : (self.playerId ?: [NSNull null]),
    @"volume" : (self.volume ?: [NSNull null]),
  };
}
@end

@implementation PositionMessage
+ (instancetype)makeWithPlayerId:(NSString *)playerId
    position:(NSNumber *)position {
  PositionMessage* pigeonResult = [[PositionMessage alloc] init];
  pigeonResult.playerId = playerId;
  pigeonResult.position = position;
  return pigeonResult;
}
+ (PositionMessage *)fromMap:(NSDictionary *)dict {
  PositionMessage *pigeonResult = [[PositionMessage alloc] init];
  pigeonResult.playerId = GetNullableObject(dict, @"playerId");
  NSAssert(pigeonResult.playerId != nil, @"");
  pigeonResult.position = GetNullableObject(dict, @"position");
  NSAssert(pigeonResult.position != nil, @"");
  return pigeonResult;
}
+ (nullable PositionMessage *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [PositionMessage fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"playerId" : (self.playerId ?: [NSNull null]),
    @"position" : (self.position ?: [NSNull null]),
  };
}
@end

@implementation PlayMessage
+ (instancetype)makeWithAccount:(NSString *)account
    policy:(NSString *)policy
    dataSource:(NSString *)dataSource
    catalogBaseUrl:(nullable NSString *)catalogBaseUrl
    dataSourceType:(DataSourceType)dataSourceType {
  PlayMessage* pigeonResult = [[PlayMessage alloc] init];
  pigeonResult.account = account;
  pigeonResult.policy = policy;
  pigeonResult.dataSource = dataSource;
  pigeonResult.catalogBaseUrl = catalogBaseUrl;
  pigeonResult.dataSourceType = dataSourceType;
  return pigeonResult;
}
+ (PlayMessage *)fromMap:(NSDictionary *)dict {
  PlayMessage *pigeonResult = [[PlayMessage alloc] init];
  pigeonResult.account = GetNullableObject(dict, @"account");
  NSAssert(pigeonResult.account != nil, @"");
  pigeonResult.policy = GetNullableObject(dict, @"policy");
  NSAssert(pigeonResult.policy != nil, @"");
  pigeonResult.dataSource = GetNullableObject(dict, @"dataSource");
  NSAssert(pigeonResult.dataSource != nil, @"");
  pigeonResult.catalogBaseUrl = GetNullableObject(dict, @"catalogBaseUrl");
  pigeonResult.dataSourceType = [GetNullableObject(dict, @"dataSourceType") integerValue];
  return pigeonResult;
}
+ (nullable PlayMessage *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [PlayMessage fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"account" : (self.account ?: [NSNull null]),
    @"policy" : (self.policy ?: [NSNull null]),
    @"dataSource" : (self.dataSource ?: [NSNull null]),
    @"catalogBaseUrl" : (self.catalogBaseUrl ?: [NSNull null]),
    @"dataSourceType" : @(self.dataSourceType),
  };
}
@end

@interface BrightcoveVideoPlayerApiCodecReader : FlutterStandardReader
@end
@implementation BrightcoveVideoPlayerApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [PlayMessage fromMap:[self readValue]];
    
    case 129:     
      return [PositionMessage fromMap:[self readValue]];
    
    case 130:     
      return [TextureMessage fromMap:[self readValue]];
    
    case 131:     
      return [VolumeMessage fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface BrightcoveVideoPlayerApiCodecWriter : FlutterStandardWriter
@end
@implementation BrightcoveVideoPlayerApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[PlayMessage class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[PositionMessage class]]) {
    [self writeByte:129];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[TextureMessage class]]) {
    [self writeByte:130];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[VolumeMessage class]]) {
    [self writeByte:131];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface BrightcoveVideoPlayerApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation BrightcoveVideoPlayerApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[BrightcoveVideoPlayerApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[BrightcoveVideoPlayerApiCodecReader alloc] initWithData:data];
}
@end


NSObject<FlutterMessageCodec> *BrightcoveVideoPlayerApiGetCodec() {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    BrightcoveVideoPlayerApiCodecReaderWriter *readerWriter = [[BrightcoveVideoPlayerApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}

void BrightcoveVideoPlayerApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<BrightcoveVideoPlayerApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.initialize"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(initializeWithError:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(initializeWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api initializeWithError:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.create"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(createMsg:error:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(createMsg:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        PlayMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        TextureMessage *output = [api createMsg:arg_msg error:&error];
        callback(wrapResult(output, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.dispose"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(disposeMsg:error:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(disposeMsg:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        TextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api disposeMsg:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.setVolume"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(setVolumeMsg:error:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(setVolumeMsg:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        VolumeMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api setVolumeMsg:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.enterPictureInPictureMode"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(enterPictureInPictureModeMsg:error:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(enterPictureInPictureModeMsg:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        TextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api enterPictureInPictureModeMsg:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.play"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(playMsg:error:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(playMsg:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        TextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api playMsg:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.pause"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(pauseMsg:error:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(pauseMsg:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        TextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api pauseMsg:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.BrightcoveVideoPlayerApi.seekTo"
        binaryMessenger:binaryMessenger
        codec:BrightcoveVideoPlayerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(seekToMsg:error:)], @"BrightcoveVideoPlayerApi api (%@) doesn't respond to @selector(seekToMsg:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        PositionMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api seekToMsg:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}