///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGGetSharedLinksResult;
@class DBSHARINGLinkMetadata;

#pragma mark - API Object

///
/// The `GetSharedLinksResult` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGGetSharedLinksResult : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Shared links applicable to the path argument.
@property (nonatomic, readonly) NSArray<DBSHARINGLinkMetadata *> * _Nonnull links;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param links Shared links applicable to the path argument.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithLinks:(NSArray<DBSHARINGLinkMetadata *> * _Nonnull)links;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `GetSharedLinksResult` struct.
///
@interface DBSHARINGGetSharedLinksResultSerializer : NSObject

///
/// Serializes `DBSHARINGGetSharedLinksResult` instances.
///
/// @param instance An instance of the `DBSHARINGGetSharedLinksResult` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGGetSharedLinksResult` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBSHARINGGetSharedLinksResult * _Nonnull)instance;

///
/// Deserializes `DBSHARINGGetSharedLinksResult` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGGetSharedLinksResult` API object.
///
/// @return An instantiation of the `DBSHARINGGetSharedLinksResult` object.
///
+ (DBSHARINGGetSharedLinksResult * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
