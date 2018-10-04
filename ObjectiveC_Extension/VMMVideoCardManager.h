//
//  VMMVideoCardManager.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 04/10/18.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#ifndef VMMVideoCardManager_Class
#define VMMVideoCardManager_Class

#import <Foundation/Foundation.h>
#import "VMMVideoCard.h"

@interface VMMVideoCardManager : NSObject

/*!
 * @discussion  Returns every available information about every available video card.
 * @return      A VMMVideoCard array with information related with every available video card.
 */
+(NSArray<VMMVideoCard*>* _Nonnull)videoCards;

/*!
 * @discussion  Returns every available information about the main video card.
 * @return      A VMMVideoCard with information related with the main video card.
 */
+(VMMVideoCard* _Nullable)mainVideoCard;

/*!
 * @discussion  Returns every available information about every unidentified video card.
 * @return      A VMMVideoCard array with information related with every unidentified video card.
 */
+(NSArray<VMMVideoCard*>*)videoCardsWithMissingKext;

@end

#endif
