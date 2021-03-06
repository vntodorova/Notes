///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBPAPERRefPaperDoc.h"
#import "DBSerializableProtocol.h"

@class DBPAPERRemovePaperDocUser;
@class DBSHARINGMemberSelector;

#pragma mark - API Object

///
/// The `RemovePaperDocUser` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBPAPERRemovePaperDocUser : DBPAPERRefPaperDoc <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// User which should be removed from the Paper doc. Specify only email or
/// Dropbox account id.
@property (nonatomic, readonly) DBSHARINGMemberSelector * _Nonnull member;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param docId (no description).
/// @param member User which should be removed from the Paper doc. Specify only
/// email or Dropbox account id.
///
/// @return An initialized instance.
///
- (nonnull instancetype)initWithDocId:(NSString * _Nonnull)docId member:(DBSHARINGMemberSelector * _Nonnull)member;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `RemovePaperDocUser` struct.
///
@interface DBPAPERRemovePaperDocUserSerializer : NSObject

///
/// Serializes `DBPAPERRemovePaperDocUser` instances.
///
/// @param instance An instance of the `DBPAPERRemovePaperDocUser` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBPAPERRemovePaperDocUser` API object.
///
+ (NSDictionary * _Nonnull)serialize:(DBPAPERRemovePaperDocUser * _Nonnull)instance;

///
/// Deserializes `DBPAPERRemovePaperDocUser` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBPAPERRemovePaperDocUser` API object.
///
/// @return An instantiation of the `DBPAPERRemovePaperDocUser` object.
///
+ (DBPAPERRemovePaperDocUser * _Nonnull)deserialize:(NSDictionary * _Nonnull)dict;

@end
