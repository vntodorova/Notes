///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMTeamFolderCreateError;

#pragma mark - API Object

///
/// The `TeamFolderCreateError` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMTeamFolderCreateError : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMTeamFolderCreateErrorTag` enum type represents the possible tag
/// states with which the `DBTEAMTeamFolderCreateError` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMTeamFolderCreateErrorTag) {
  /// The provided name cannot be used.
  DBTEAMTeamFolderCreateErrorInvalidFolderName,

  /// There is already a team folder with the provided name.
  DBTEAMTeamFolderCreateErrorFolderNameAlreadyUsed,

  /// The provided name cannot be used because it is reserved.
  DBTEAMTeamFolderCreateErrorFolderNameReserved,

  /// (no description).
  DBTEAMTeamFolderCreateErrorOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMTeamFolderCreateErrorTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "invalid_folder_name".
///
/// Description of the "invalid_folder_name" tag state: The provided name cannot
/// be used.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithInvalidFolderName;

///
/// Initializes union class with tag state of "folder_name_already_used".
///
/// Description of the "folder_name_already_used" tag state: There is already a
/// team folder with the provided name.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithFolderNameAlreadyUsed;

///
/// Initializes union class with tag state of "folder_name_reserved".
///
/// Description of the "folder_name_reserved" tag state: The provided name
/// cannot be used because it is reserved.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithFolderNameReserved;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithOther;

- (nonnull instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value
/// "invalid_folder_name".
///
/// @return Whether the union's current tag state has value
/// "invalid_folder_name".
///
- (BOOL)isInvalidFolderName;

///
/// Retrieves whether the union's current tag state has value
/// "folder_name_already_used".
///
/// @return Whether the union's current tag state has value
/// "folder_name_already_used".
///
- (BOOL)isFolderNameAlreadyUsed;

///
/// Retrieves whether the union's current tag state has value
/// "folder_name_reserved".
///
/// @return Whether the union's current tag state has value
/// "folder_name_reserved".
///
- (BOOL)isFolderNameReserved;

///
/// Retrieves whether the union's current tag state has value "other".
///
/// @return Whether the union's current tag state has value "other".
///
- (BOOL)isOther;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString * _Nonnull)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBTEAMTeamFolderCreateError` union.
///
@interface DBTEAMTeamFolderCreateErrorSerializer : NSObject

///
/// Serializes `DBTEAMTeamFolderCreateError` instances.
///
/// @param instance An instance of the `DBTEAMTeamFolderCreateError` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMTeamFolderCreateError` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBTEAMTeamFolderCreateError * _Nonnull)instance;

///
/// Deserializes `DBTEAMTeamFolderCreateError` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMTeamFolderCreateError` API object.
///
/// @return An instantiation of the `DBTEAMTeamFolderCreateError` object.
///
+ (DBTEAMTeamFolderCreateError * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
