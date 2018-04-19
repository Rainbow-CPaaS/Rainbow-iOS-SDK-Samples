/*
 * Rainbow
 *
 * Copyright (c) 2016, ALE International
 * All rights reserved.
 *
 * ALE International Proprietary Information
 *
 * Contains proprietary/trade secret information which is the property of
 * ALE International and must not be made available to, or copied or used by
 * anyone outside ALE International without its written authorization
 *
 * Not to be disclosed or used except in accordance with applicable agreements.
 */

#import <Foundation/Foundation.h>
#import "Group.h"

/** @name Groups service Notifications */
/** Groups service notification sent when a group is added 
 *  Group added is sent in notification object
 */
FOUNDATION_EXPORT NSString *const kGroupsServiceDidAddGroup;
/** Groups service notification sent when a group is updated (new contact added) 
 *  Group updated is sent in notification object
 */
FOUNDATION_EXPORT NSString *const kGroupsServiceDidUpdateGroup;
/**
 *  Groups service notifications sent when a contact is added/removed from a group
 *  Notification object sent the concerned contact
 */
FOUNDATION_EXPORT NSString *const kGroupsServiceDidUpdateGroupsForContact;
/** Groups service notification sent when a group is remove 
 *  Group removed is sent in notification object
 */
FOUNDATION_EXPORT NSString *const kGroupsServiceDidRemoveGroup;
/** Groups service notification sent when all groups are removed */
FOUNDATION_EXPORT NSString *const kGroupsServiceDidRemoveAllGroups;


@interface GroupsService : NSObject
/**
 *  List of all groups
 */
@property (nonatomic, readonly) NSArray<Group *> *groups;

/**
 *  Create a group on server side with the given name
 *
 *  @param name the name of the group
 *  @param comment an option comment for the group
 *  @return the group created
 */
-(Group *) createGroupWithName:(NSString *) name andComment:(NSString *) comment;

/**
 *  Delete the given group
 *
 *  @param group Group to delete
 */
-(void) deleteGroup:(Group *) group;

/**
 *  Update the given group with the new given name
 *
 *  @param group        The group to update
 *  @param newGroupName The new name to set in the group
 */
-(void) updateGroup:(Group *) group withNewGroupName:(NSString *) newGroupName;

/**
 *  Update the given group with the new comment
 *
 *  @param group      The group to update
 *  @param newComment The new comment to set in the group
 */
-(void) updateGroup:(Group *) group withNewComment:(NSString *) newComment;

/**
 *  Add the given contact in the given group
 *
 *  @param contact The contact to add in the group
 *  @param group   The group where we add the given contact
 */
-(void) addContact:(Contact *) contact inGroup:(Group *) group;

/**
 *  Remove the given contact from the given group
 *
 *  @param contact The contact to remove from the given group
 *  @param group   The group where the given contact must be removed
 */
-(void) removeContact:(Contact *) contact fromGroup:(Group *) group;

/**
 *  Return all groups for the given contact
 *
 *  @param contact the contact for which we want the list of groups
 *
 *  @return Array of groups where this contact have been found
 */
-(NSArray <Group*> *) groupsForContact:(Contact *) contact;

/**
 *  Search in group name for the given pattern.
 *  This method perform the search action synchronously, so be sure to not invoke it in main thread
 *  @param pattern  pattern to search
 *  @return list of groups that match the given pattern
 */
-(NSArray<Group *> *) searchGroupsWithPattern:(NSString *) pattern;
@end
