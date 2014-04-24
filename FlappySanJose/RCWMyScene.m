//
//  RCWMyScene.m
//  FlappySanJose
//
//  Created by Jonathan on 4/24/14.
//  Copyright (c) 2014 Rubber City Wizards. All rights reserved.
//

#import "RCWMyScene.h"

typedef NS_ENUM(NSUInteger, Category) {
    CategoryWall = 1 << 0,
    CategoryPipe = 1 << 1,
    CategoryBird = 1 << 2,
};

@interface RCWMyScene ()
<SKPhysicsContactDelegate>
@property (nonatomic) NSInteger counter;
@end

@implementation RCWMyScene

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.physicsWorld.gravity = CGVectorMake(0, -3);
        self.physicsWorld.contactDelegate = self;

        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = CategoryWall;
        self.physicsBody.contactTestBitMask = CategoryBird;

        SKSpriteNode *bird = [SKSpriteNode spriteNodeWithImageNamed:@"flap-1"];
        bird.name = @"bird";
        bird.size = CGSizeMake(40, 40);
        bird.position = CGPointMake(size.width/2 - 50, size.height/2);
        [self addChild:bird];

        NSArray *frames = @[
                            [SKTexture textureWithImageNamed:@"flap-1"],
                            [SKTexture textureWithImageNamed:@"flap-2"],
                            [SKTexture textureWithImageNamed:@"flap-3"],
                            [SKTexture textureWithImageNamed:@"flap-4"]
                            ];

        SKAction *flap = [SKAction animateWithTextures:frames timePerFrame:0.1];
        SKAction *flapForever = [SKAction repeatActionForever:flap];

        [bird runAction:flapForever];
        bird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bird.size.width - 10, bird.size.height - 10)];
        bird.physicsBody.density = 0.3;
        bird.physicsBody.categoryBitMask = CategoryBird;
        bird.physicsBody.contactTestBitMask = CategoryPipe | CategoryWall;
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime
{
    self.counter++;
    if (self.counter % 180 == 0) {
        [self deployPipe];
    }
}

- (void)deployPipe
{
    SKSpriteNode *pipe1 = [SKSpriteNode spriteNodeWithImageNamed:@"pipe"];
    pipe1.size = CGSizeMake(50, 50 + arc4random_uniform(150));
    pipe1.name = @"pipe";
    pipe1.position = CGPointMake(self.size.width + 200, pipe1.size.height/2);
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.categoryBitMask = CategoryPipe;
    pipe1.physicsBody.dynamic = NO;
    [self addChild:pipe1];

    SKSpriteNode *pipe2 = [pipe1 copy];
    pipe2.size = CGSizeMake(pipe1.size.width, self.size.height - pipe1.size.height - 200);
    pipe2.zRotation = M_PI;
    pipe2.position = CGPointMake(pipe1.position.x, self.size.height - pipe2.size.height/2);
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe2.physicsBody.categoryBitMask = CategoryPipe;
    pipe2.physicsBody.dynamic = NO;
    [self addChild:pipe2];

    SKAction *move = [SKAction moveToX:-200 duration:13];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];

    [pipe1 runAction:moveAndRemove];
    [pipe2 runAction:moveAndRemove];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKNode *bird = [self childNodeWithName:@"bird"];

    [bird.physicsBody applyImpulse:CGVectorMake(0, 5)];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *bird = [self childNodeWithName:@"bird"];
    [bird removeFromParent];
}

@end
