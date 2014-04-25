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
    CategorySensor = 1 << 3,
};

@interface RCWMyScene ()
<SKPhysicsContactDelegate>
@property (nonatomic) NSInteger counter;
@property (nonatomic) NSInteger score;
@property (nonatomic, strong) SKEmitterNode *explosionTemplate;
@end

@implementation RCWMyScene

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        NSURL *explosionURL = [[NSBundle mainBundle] URLForResource:@"explosion" withExtension:@"sks"];
        self.explosionTemplate = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionURL.path];

        [self startGame];
    }
    return self;
}

- (void)startGame
{
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    self.physicsWorld.contactDelegate = self;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = CategoryWall;
    self.physicsBody.contactTestBitMask = CategoryBird;

    SKSpriteNode *sky = [SKSpriteNode spriteNodeWithImageNamed:@"sky"];
    sky.size = CGSizeMake(self.size.width*2, self.size.height);
    sky.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:sky];

    SKSpriteNode *bird = [SKSpriteNode spriteNodeWithImageNamed:@"flap-1"];
    bird.name = @"bird";
    bird.size = CGSizeMake(40, 40);
    bird.position = CGPointMake(self.size.width/2 - 50, self.size.height/2);
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

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(-3.5, 20.5)];
    [bezierPath addLineToPoint: CGPointMake(19.5, 9.5)];
    [bezierPath addLineToPoint: CGPointMake(11.5, -9.5)];
    [bezierPath addLineToPoint: CGPointMake(6.5, -18.5)];
    [bezierPath addLineToPoint: CGPointMake(-15.5, -18.5)];
    [bezierPath addLineToPoint: CGPointMake(-19.5, -9.5)];
    [bezierPath addLineToPoint: CGPointMake(-3.5, 20.5)];

    bird.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:bezierPath.CGPath];
    bird.physicsBody.density = 0.3;
    bird.physicsBody.categoryBitMask = CategoryBird;
    bird.physicsBody.contactTestBitMask = CategoryPipe | CategoryWall | CategorySensor;
    bird.physicsBody.collisionBitMask ^= CategorySensor;


    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    scoreLabel.fontSize = 10;
    scoreLabel.name = @"scoreLabel";
    scoreLabel.text = @"You have passed 0 pipe(s)!";
    scoreLabel.position = CGPointMake(self.size.width - 20, self.size.height - 20);
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    scoreLabel.zPosition = 10;
    scoreLabel.fontColor = [SKColor blackColor];

    [self addChild:scoreLabel];
}

- (void)reset
{
    self.score = 0;
    [self removeAllActions];
    [self removeAllChildren];
}

- (void)passPipe
{
    self.score++;
    SKLabelNode *scoreLabel = (id)[self childNodeWithName:@"scoreLabel"];
    scoreLabel.text = [NSString stringWithFormat:@"You have passed %d pipe(s)!", self.score];
}

- (void)update:(NSTimeInterval)currentTime
{
    self.counter++;
    if (self.counter % 240 == 0) {
        [self deployPipe];
    }
}

- (void)deployPipe
{
    SKSpriteNode *pipe1 = [SKSpriteNode spriteNodeWithImageNamed:@"pipe"];
    pipe1.size = CGSizeMake(50, 50 + arc4random_uniform(150));
    pipe1.name = @"pipe";
    pipe1.position = CGPointMake(self.size.width + 50, pipe1.size.height/2);
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.categoryBitMask = CategoryPipe;
    pipe1.physicsBody.dynamic = NO;
    [self addChild:pipe1];

    SKSpriteNode *pipe2 = [pipe1 copy];
    pipe2.size = CGSizeMake(pipe1.size.width, self.size.height - pipe1.size.height - 120);
    pipe2.zRotation = M_PI;
    pipe2.position = CGPointMake(pipe1.position.x, self.size.height - pipe2.size.height/2);
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.categoryBitMask = CategoryPipe;
    pipe2.physicsBody.dynamic = NO;
    [self addChild:pipe2];

    SKNode *sensor = [SKNode node];
    sensor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(3, self.size.height)];
    sensor.physicsBody.dynamic = NO;
    sensor.physicsBody.categoryBitMask = CategorySensor;
    sensor.position = CGPointMake(pipe1.position.x, self.size.height/2);
    [self addChild:sensor];

    SKAction *move = [SKAction moveToX:-200 duration:13];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];

    [pipe1 runAction:moveAndRemove];
    [pipe2 runAction:moveAndRemove];
    [sensor runAction:moveAndRemove];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKNode *bird = [self childNodeWithName:@"bird"];

    if (!bird) {
        [self reset];
        [self startGame];
    } else {
        [bird.physicsBody applyImpulse:CGVectorMake(0, 4.5)];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKSpriteNode *bird = (id)[self childNodeWithName:@"bird"];

    NSPredicate *isPipe = [NSPredicate predicateWithFormat:@"self.node.name == %@", @"pipe"];

    NSArray *pipeBodies = [bird.physicsBody.allContactedBodies filteredArrayUsingPredicate:isPipe];

    if ([pipeBodies count] > 0) {
        [self endGame];
    } else {
        if (bird.position.y <= bird.size.height) {
            [self endGame];
        }
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == CategorySensor || contact.bodyB.categoryBitMask == CategorySensor) {
        [self passPipe];
    }
}

- (void)endGame
{
    SKSpriteNode *bird = (id)[self childNodeWithName:@"bird"];
    [bird removeFromParent];

    SKEmitterNode *explosion = [self.explosionTemplate copy];
    explosion.position = bird.position;
    SKAction *dieOut = [SKAction runBlock:^{
        explosion.particleBirthRate = 0;
    }];
    SKAction *all = [SKAction sequence:@[
                                         [SKAction waitForDuration:0.1],
                                         dieOut,
                                         [SKAction waitForDuration:1],
                                         [SKAction removeFromParent]]];
    [explosion runAction:all];
    [self addChild:explosion];
}

@end
