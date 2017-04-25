///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMGroupsMembersListContinueArg;

#pragma mark - API Object

///
/// The `GroupsMembersListContinueArg` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMGroupsMembersListContinueArg : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Indicates from what point to get the next set of groups.
@property (nonatomic, readonly, copy) NSString * _Nonnull cursor;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param cursor Indicates from what point to get the next set of groups.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithCursor:(NSString * _Nonnull)cursor;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `GroupsMembersListContinueArg` struct.
///
@interface DBTEAMGroupsMembersListContinueArgSerializer : NSObject

///
/// Serializes `DBTEAMGroupsMembersListContinueArg` instances.
///
/// @param instance An instance of the `DBTEAMGroupsMembersListContinueArg` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMGroupsMembersListContinueArg` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBTEAMGroupsMembersListContinueArg * _Nonnull)instance;

///
/// Deserializes `DBTEAMGroupsMembersListContinueArg` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMGroupsMembersListContinueArg` API object.
///
/// @return An instantiation of the `DBTEAMGroupsMembersListContinueArg` object.
///
+ (DBTEAMGroupsMembersListContinueArg * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
