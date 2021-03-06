//
//  HostImporter.m
//  SelfControl
//
//  Created by Charlie Stigler on 2/16/09.
//  Copyright 2009 Eyebeam.

// This file is part of SelfControl.
//
// SelfControl is free software:  you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import "HostImporter.h"

@implementation HostImporter

+ (NSArray*)incomingMailHostnamesFromMail {
	NSMutableArray* hostnames = [NSMutableArray arrayWithCapacity: 10];
	NSDictionary* defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName: @"com.apple.Mail"];
	NSArray* incomingAccounts = defaults[@"MailAccounts"];
	for(int i = 0; i < [incomingAccounts count]; i++) {
		NSMutableString* hostname = [incomingAccounts[i][@"Hostname"] mutableCopy];
		// The LocalAccountName account has no hostname, so trying to add it would cause an error
		if(hostname != nil) {
			// If it has a defined port number, add it to the host to block for added
			// block specificity, so only incoming mail is blocked.
			if(incomingAccounts[i][@"PortNumber"] != nil) {
				[hostname appendString: @":"];
				[hostname appendString: incomingAccounts[i][@"PortNumber"]];
				// If it doesn't have a defined port number, we'll go through and choose
				// the default port for the type of account it is.
			} else if([incomingAccounts[i][@"AccountType"] isEqual: @"POPAccount"]) {
				if(incomingAccounts[i][@"SSLEnabled"]) {
					[hostname appendString: @":"];
					[hostname appendString: @"995"];
				} else {
					[hostname appendString: @":"];
					[hostname appendString: @"110"];
				}
			} else if([incomingAccounts[i][@"AccountType"] isEqual: @"IMAPAccount"]) {
				if(incomingAccounts[i][@"SSLEnabled"]) {
					[hostname appendString: @":"];
					[hostname appendString: @"993"];
				} else {
					[hostname appendString: @":"];
					[hostname appendString: @"143"];
				}
			}
			[hostnames addObject: hostname];
		}
	}

	return hostnames;
}

+ (NSArray*)outgoingMailHostnamesFromMail {
	NSMutableArray* hostnames = [NSMutableArray arrayWithCapacity: 10];
	NSDictionary* defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName: @"com.apple.Mail"];
	NSArray* outgoingAccounts = defaults[@"DeliveryAccounts"];
	for(int i = 0; i < [outgoingAccounts count]; i++) {
		NSMutableString* hostname = [outgoingAccounts[i][@"Hostname"] mutableCopy];
		if(hostname != nil) {
			if(outgoingAccounts[i][@"PortNumber"] != nil) {
				[hostname appendString: @":"];
				[hostname appendString: outgoingAccounts[i][@"PortNumber"]];
				// If it doesn't have a defined port number, we'll go through and choose
				// the default port for the type of account it is.
			} else {
				[hostnames addObject: [hostname stringByAppendingString: @":25"]];
				[hostnames addObject: [hostname stringByAppendingString: @":465"]];
				[hostname appendString: @":587"];
			}

			[hostnames addObject: hostname];
		}
	}

	return hostnames;
}

+ (NSArray*)incomingMailHostnamesFromThunderbird {
	return [ThunderbirdPreferenceParser incomingHostnames];
}

+ (NSArray*)outgoingMailHostnamesFromThunderbird {
	return [ThunderbirdPreferenceParser outgoingHostnames];
}

@end