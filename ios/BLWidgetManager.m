//
//  BLWidgetManager.m
//  TerraRtReact
//
//  Created by Elliott Yu on 19/05/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTBridgeModule.h>) || __has_include("RCTBridgeModule.h")

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#import "RCTViewManager.h"
#endif

#ifdef RCT_NEW_ARCH_ENABLED
#if __has_include(<React/RCTFabricComponentsPlugins.h>)
#import <React/RCTFabricComponentsPlugins.h>
#endif
#endif

#ifdef RCT_NEW_ARCH_ENABLED
@interface RCT_EXTERN_REMAP_MODULE(BLWidgetManager, BLWidgetManager, RCTViewManager)
#else
@interface RCT_EXTERN_MODULE(BLWidgetManager, RCTViewManager)
#endif

RCT_EXPORT_VIEW_PROPERTY(withCache, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onSuccessfulConnection, RCTDirectEventBlock)

@end

#ifdef RCT_NEW_ARCH_ENABLED
Class RCTViewManagerClassForBLWidgetManager(void)
{
	return BLWidgetManager.class;
}
#endif

#endif
