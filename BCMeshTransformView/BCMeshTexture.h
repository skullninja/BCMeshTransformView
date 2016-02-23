//
//  BCMeshTexture.h
//  BCMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCMeshTexture : NSObject

@property (readonly) BOOL isEmpty;
@property (nonatomic, assign) BOOL checkForEmptyTexture;
@property (nonatomic, readonly) GLuint texture;

- (void)setupOpenGL;
- (void)renderView:(UIView *)view;

- (void)renderView:(UIView *)view screenUpdates:(BOOL)screenUpdates;

@end
