//
//  MyGPUImageFilter5.m
//  SimpleImageFilter
//
//  Created by shangbocai on 14-9-23.
//  Copyright (c) 2014年 Cell Phone. All rights reserved.
//

#import "MyGPUImageFilter5.h"



NSString *const kIFEarlybirdShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //earlyBirdCurves
 uniform sampler2D inputImageTexture3; //earlyBirdOverlay
 uniform sampler2D inputImageTexture4; //vig
 uniform sampler2D inputImageTexture5; //earlyBirdBlowout
 uniform sampler2D inputImageTexture6; //earlyBirdMap
 
 const mat3 saturate = mat3(
                            1.210300,
                            -0.089700,
                            -0.091000,
                            -0.176100,
                            1.123900,
                            -0.177400,
                            -0.034200,
                            -0.034200,
                            1.265800);
 const vec3 rgbPrime = vec3(0.25098, 0.14640522, 0.0);
 const vec3 desaturate = vec3(.3, .59, .11);
 
 void main()
 {
     
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     
     vec2 lookup;
     lookup.y = 0.5;
     
     lookup.x = texel.r;
     texel.r = texture2D(inputImageTexture2, lookup).r;
     
     lookup.x = texel.g;
     texel.g = texture2D(inputImageTexture2, lookup).g;
     
     lookup.x = texel.b;
     texel.b = texture2D(inputImageTexture2, lookup).b;
     
     float desaturatedColor;
     vec3 result;
     desaturatedColor = dot(desaturate, texel);
     
     
     lookup.x = desaturatedColor;
     result.r = texture2D(inputImageTexture3, lookup).r;
     lookup.x = desaturatedColor;
     result.g = texture2D(inputImageTexture3, lookup).g;
     lookup.x = desaturatedColor;
     result.b = texture2D(inputImageTexture3, lookup).b;
     
     texel = saturate * mix(texel, result, .5);
     
     vec2 tc = (2.0 * textureCoordinate) - 1.0;
     float d = dot(tc, tc);
     
     vec3 sampled;
     lookup.y = .5;
     
     /*
      lookup.x = texel.r;
      sampled.r = texture2D(inputImageTexture4, lookup).r;
      
      lookup.x = texel.g;
      sampled.g = texture2D(inputImageTexture4, lookup).g;
      
      lookup.x = texel.b;
      sampled.b = texture2D(inputImageTexture4, lookup).b;
      
      float value = smoothstep(0.0, 1.25, pow(d, 1.35)/1.65);
      texel = mix(texel, sampled, value);
      */
     
     //---
     
     lookup = vec2(d, texel.r);
     texel.r = texture2D(inputImageTexture4, lookup).r;
     lookup.y = texel.g;
     texel.g = texture2D(inputImageTexture4, lookup).g;
     lookup.y = texel.b;
     texel.b	= texture2D(inputImageTexture4, lookup).b;
     float value = smoothstep(0.0, 1.25, pow(d, 1.35)/1.65);
     
     //---
     
     lookup.x = texel.r;
     sampled.r = texture2D(inputImageTexture5, lookup).r;
     lookup.x = texel.g;
     sampled.g = texture2D(inputImageTexture5, lookup).g;
     lookup.x = texel.b;
     sampled.b = texture2D(inputImageTexture5, lookup).b;
     texel = mix(sampled, texel, value);
     
     
     lookup.x = texel.r;
     texel.r = texture2D(inputImageTexture6, lookup).r;
     lookup.x = texel.g;
     texel.g = texture2D(inputImageTexture6, lookup).g;
     lookup.x = texel.b;
     texel.b = texture2D(inputImageTexture6, lookup).b;
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );


@interface MyGPUImageFilter5 ()
{
    GPUImageFramebuffer *InputFramebuffer2;
    GPUImageFramebuffer *InputFramebuffer3;
    GPUImageFramebuffer *InputFramebuffer4;
    GPUImageFramebuffer *InputFramebuffer5;
    GPUImageFramebuffer *InputFramebuffer6;
    
    int _index ;
    
    CMTime firstFrameTime;
    
    
    bool textureIndexTimed;
    bool textureIndexTimed1;
    bool textureIndexTimed2;
    bool textureIndexTimed3;
    bool textureIndexTimed4;
    bool textureIndexTimed5;
    
    GLint  filterInputTextureUniform2, filterInputTextureUniform3, filterInputTextureUniform4, filterInputTextureUniform5, filterInputTextureUniform6;
    
}

@end

@implementation MyGPUImageFilter5

#pragma mark -
#pragma mark Initialization and teardown

- (id) init {
    if (!(self = [self initWithFragmentShaderFromString:kIFEarlybirdShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    textureIndexTimed = true;
    textureIndexTimed1 = true;
    textureIndexTimed2 = true;
    textureIndexTimed3 = true;
    textureIndexTimed4 = true;
    textureIndexTimed5 = true;
    
    _index = 0;
    
    [GPUImageContext useImageProcessingContext];
    filterProgram = [[GLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:fragmentShaderString];
    
    [filterProgram addAttribute:@"position"];
    [filterProgram addAttribute:@"inputTextureCoordinate"];
    
    if (![filterProgram link])
    {
        NSString *progLog = [filterProgram programLog];
        NSLog(@"Program link log: %@", progLog);
        NSString *fragLog = [filterProgram fragmentShaderLog];
        NSLog(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [filterProgram vertexShaderLog];
        NSLog(@"Vertex shader compile log: %@", vertLog);
        filterProgram = nil;
        NSAssert(NO, @"Filter shader link failed");
    }
    
    filterPositionAttribute = [filterProgram attributeIndex:@"position"];
    filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
    filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
    filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
    filterInputTextureUniform3 = [filterProgram uniformIndex:@"inputImageTexture3"]; // This does assume a name of "inputImageTexture3" for second input texture in the fragment shader
    filterInputTextureUniform4 = [filterProgram uniformIndex:@"inputImageTexture4"]; // This does assume a name of "inputImageTexture4" for second input texture in the fragment shader
    filterInputTextureUniform5 = [filterProgram uniformIndex:@"inputImageTexture5"]; // This does assume a name of "inputImageTexture5" for second input texture in the fragment shader
    filterInputTextureUniform6 = [filterProgram uniformIndex:@"inputImageTexture6"]; // This does assume a name of "inputImageTexture6" for second input texture in the fragment shader
    
    
    [filterProgram use];
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    
    return self;
}


#pragma mark -
#pragma mark Managing the display FBOs

- (CGSize)sizeOfFBO;
{
    CGSize outputSize = [self maximumOutputSize];
    if ( (CGSizeEqualToSize(outputSize, CGSizeZero)) || (inputTextureSize.width < outputSize.width) )
    {
        return inputTextureSize;
    }
    else
    {
        return outputSize;
    }
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
	
	glUniform1i(filterInputTextureUniform, 2);
    
    if (InputFramebuffer2 != 0)
    {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [InputFramebuffer2 texture]);
        
        glUniform1i(filterInputTextureUniform2 , 3);
    }
    if (InputFramebuffer3 != 0)
    {
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [InputFramebuffer3 texture]);
        glUniform1i(filterInputTextureUniform3, 4);
    }
    if (InputFramebuffer4 != 0)
    {
        glActiveTexture(GL_TEXTURE5);
        glBindTexture(GL_TEXTURE_2D, [InputFramebuffer4 texture]);
        
        glUniform1i(filterInputTextureUniform4 , 5);
    }
    if (InputFramebuffer5 != 0)
    {
        glActiveTexture(GL_TEXTURE6);
        glBindTexture(GL_TEXTURE_2D, [InputFramebuffer5 texture]);
        glUniform1i(filterInputTextureUniform5, 6);
    }
    if (InputFramebuffer6 != 0)
    {
        glActiveTexture(GL_TEXTURE7);
        glBindTexture(GL_TEXTURE_2D, [InputFramebuffer6 texture]);
        glUniform1i(filterInputTextureUniform6, 7);
    }
    
    
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}


- (NSInteger)nextAvailableTextureIndex;
{
    return _index++;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        
        [firstInputFramebuffer lock];
        textureIndexTimed = false;
    }
    else if(textureIndex == 1)
    {
        InputFramebuffer2 = newInputFramebuffer;
        [InputFramebuffer2 lock];
        textureIndexTimed1 = false;
    }
    else if(textureIndex == 2)
    {
        InputFramebuffer3 = newInputFramebuffer;
        [InputFramebuffer3 lock];
        textureIndexTimed2 = false;
    }
    else if(textureIndex == 3)
    {
        InputFramebuffer4 = newInputFramebuffer;
        [InputFramebuffer4 lock];
        textureIndexTimed3 = false;
    }
    else if(textureIndex == 4)
    {
        InputFramebuffer5 = newInputFramebuffer;
        [InputFramebuffer5 lock];
        textureIndexTimed4 = false;
    }
    else if(textureIndex == 5)
    {
        InputFramebuffer6 = newInputFramebuffer;
        [InputFramebuffer6 lock];
        textureIndexTimed5 = false;
    }
    else
    {
        NSLog(@"setInputFramebuffer 多了\n");
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        [super setInputSize:newSize atIndex:textureIndex];
        
        //        if (CGSizeEqualToSize(newSize, CGSizeZero))
        //        {
        //            hasSetFirstTexture = NO;
        //        }
    }
}



- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    if(textureIndex == 0){
        firstFrameTime = frameTime;
        textureIndexTimed = true;
    } else if(textureIndex ==1) {
        textureIndexTimed1 = true;
    } else if(textureIndex ==2) {
        textureIndexTimed2 = true;
    } else if(textureIndex ==3) {
        textureIndexTimed3 = true;
    } else if(textureIndex ==4) {
        textureIndexTimed4 = true;
    } else if(textureIndex ==5) {
        textureIndexTimed5 = true;
    }
    
    if((textureIndexTimed && textureIndexTimed1 && textureIndexTimed2 &&textureIndexTimed3
        &&textureIndexTimed4 &&textureIndexTimed5))//|| updatedMovieFrameOppositeStillImage)
    {
        //CMTime passOnFrameTime = (!CMTIME_IS_INDEFINITE(firstFrameTime)) ? firstFrameTime : secondFrameTime;
        [super newFrameReadyAtTime:firstFrameTime atIndex:0]; // Bugfix when trying to record: always use time from first input (unless indefinite, in which case use the second input)
        
        textureIndexTimed = false;
        if(InputFramebuffer2 != Nil)
            textureIndexTimed1 = false;
        if(InputFramebuffer3 != Nil)
            textureIndexTimed2 = false;
        if(InputFramebuffer4 != Nil)
            textureIndexTimed3 = false;
        if(InputFramebuffer5 != Nil)
            textureIndexTimed4 = false;
        if(InputFramebuffer6 != Nil)
            textureIndexTimed5 = false;
    }
    
    
}


@end
