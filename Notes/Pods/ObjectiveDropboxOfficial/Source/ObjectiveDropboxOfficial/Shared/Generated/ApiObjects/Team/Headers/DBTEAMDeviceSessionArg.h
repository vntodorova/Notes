///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMDeviceSessionArg;

#pragma mark - API Object

///
/// The `DeviceSessionArg` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMDeviceSessionArg : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The session id
@property (nonatomic, readonly, copy) NSString * _Nonnull sessionId;

/// The unique id of the member owning the device
@property (nonatomic, readonly, copy) NSString * _Nonnull teamMemberId;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param sessionId The session id
/// @param teamMemberId The unique id of the member owning the device
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithSessionId:(NSString * _Nonnull)sessionId teamMemberId:(NSString * _Nonnull)teamMemberId;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DeviceSessionArg` struct.
///
@interface DBTEAMDeviceSessionArgSerializer : NSObject

///
/// Serializes `DBTEAMDeviceSessionArg` instances.
///
/// @param instance An instance of the `DBTEAMDeviceSessionArg` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMDeviceSessionArg` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBTEAMDeviceSessionArg * _Nonnull)instance;

///
/// Deserializes `DBTEAMDeviceSessionArg` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMDeviceSessionArg` API object.
///
/// @return An instantiation of the `DBTEAMDeviceSessionArg` object.
///
+ (DBTEAMDeviceSessionArg * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
