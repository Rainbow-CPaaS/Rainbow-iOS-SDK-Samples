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
#import "Company.h"
#import "CompanyInvitation.h"
#import "Contact.h"

FOUNDATION_EXPORT NSString *const kCompaniesServiceDidAddCompanyInvitation;
FOUNDATION_EXPORT NSString *const kCompaniesServiceDidUpdateCompanyInvitation;
FOUNDATION_EXPORT NSString *const kCompaniesServiceDidRemoveCompanyInvitation;
FOUNDATION_EXPORT NSString *const kCompaniesServiceDidUpdateCompanyInvitationPendingNumber;
FOUNDATION_EXPORT NSString *const kCompaniesServiceDidUpdateCompany;

/**
 *  Search completion handler invoked when a searching a company
 *
 *  @param searchPattern pattern searched
 *  @param foundCompanies list of companies found
 */
typedef void (^CompaniesServiceSearchCompanyCompletionHandler)(NSString *searchPattern, NSArray<Company *>* foundCompanies);

typedef void (^CompaniesServiceRequestJoinCompanyCompletionHandler) (Company* company, CompanyInvitation *companyInvitation, NSError *error);

@interface CompaniesService : NSObject

-(NSInteger) totalNbOfPendingCompanyInvitations;

/**
 *  Send a search request to server with given pattern.
 Will invoke completionBlock with an array of `Company`found, or an `NSError` if it encounter an error.
 *
 *  @param pattern         the searched pattern
 *  @param completionBlock the completion handler to invoked when the search is ended. Return an array of `Company` found or an `NSError` in case of error
 */
-(void) searchRainbowCompaniesWithPattern:(NSString *) pattern withCompletionBlock:(CompaniesServiceSearchCompanyCompletionHandler) completionBlock;

// Request to join the given company
-(void) requestJoinCompany:(Company *) company withCompletionHandler:(CompaniesServiceRequestJoinCompanyCompletionHandler) completionHandler;

-(void) cancelRequestedJoinCompany:(Company *) company withCompletionHandler:(CompaniesServiceRequestJoinCompanyCompletionHandler) completionHandler;
-(void) resendRequestJoinCompany:(Company *) company withCompletionHandler:(CompaniesServiceRequestJoinCompanyCompletionHandler) completionHandler;


-(void) acceptCompanyInvitation:(CompanyInvitation *) companyInvitation;
-(void) declineCompanyInvitation:(CompanyInvitation *) companyInvitation;
@end
