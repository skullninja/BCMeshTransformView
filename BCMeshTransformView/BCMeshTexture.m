//
//  BCMeshTexture.m
//  BCMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "BCMeshTexture.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct
{
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    uint8_t alpha;
} MyPixel_T;

@interface BCMeshTexture ()
@property (assign) BOOL isEmpty;
@end

@implementation BCMeshTexture

@synthesize isEmpty = _isEmpty;
@synthesize checkForEmptyTexture = _checkForEmptyTexture;

- (id)init {
    self = [super init];
    if (self) {
        self.checkForEmptyTexture = NO;
    }
    return self;
}

- (void)setupOpenGL
{
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)dealloc
{
    if (_texture) {
        glDeleteTextures(1, &_texture);
    }
}

- (void)renderView:(UIView *)view {
    [self renderView:view screenUpdates:NO];
}

- (void)renderView:(UIView *)view screenUpdates:(BOOL)screenUpdates {
    
    const CGFloat Scale = [UIScreen mainScreen].scale;
    
    GLsizei width = view.layer.bounds.size.width * Scale;
    GLsizei height = view.layer.bounds.size.height * Scale;
    
    GLubyte *texturePixelBuffer = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(texturePixelBuffer,
                                                 width, height, 8, width * 4, colorSpace,
                                                 kCGImageAlphaPremultipliedLast |
                                                 kCGBitmapByteOrder32Big);
    CGContextScaleCTM(context, Scale, Scale);
    
    UIGraphicsPushContext(context);
    
    [view drawViewHierarchyInRect:view.layer.bounds afterScreenUpdates:screenUpdates];
    
    if (self.checkForEmptyTexture) {
        //Get pixel data for the image
        MyPixel_T *pixels = CGBitmapContextGetData(context);
        size_t pixelCount = width * height;
        self.isEmpty = YES;
        for(size_t i = 0; i < pixelCount; i++)
        {
            MyPixel_T p = pixels[i];
            //Your definition of what's blank may differ from mine
            if(p.red > 0 || p.green > 0 || p.blue > 0 || p.alpha > 0) {
                self.isEmpty = NO;
                break;
            }
        }
        
        NSLog(@"EMPTY BUFFER: %@", self.isEmpty ? @"YES" : @"NO");
    } else {
        self.isEmpty = NO;
    }
    
    UIGraphicsPopContext();
    
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texturePixelBuffer);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(texturePixelBuffer);
}

- (void)setCheckForEmptyTexture:(BOOL)checkForEmptyTexture {
    _checkForEmptyTexture = checkForEmptyTexture;
    self.isEmpty = YES;
}

- (BOOL)checkForEmptyTexture {
    return _checkForEmptyTexture;
}

@end