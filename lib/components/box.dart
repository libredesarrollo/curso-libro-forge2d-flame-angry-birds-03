import 'dart:async';

import 'package:angry03/utils/create_animation_by_limit.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class BoxBody extends BodyComponent {
  final Vector2 position;
  bool boxAdded = false;

  double greaterImpact = 0;
  double valueToDestroy;

  late final SpriteAnimation explotionAnimation;

  BoxBody({required this.position, this.valueToDestroy = 200});
  @override
  Body createBody() {
    Shape shape = PolygonShape()..setAsBoxXY(2, 2);

    BodyDef bodyDef = BodyDef(position: position, type: BodyType.dynamic);

    FixtureDef fixtureDef =
        FixtureDef(shape, friction: 1, density: 1, userData: this);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    if (body.linearVelocity == Vector2.all(0) && !boxAdded) {
      boxAdded = true;
    }

    if (boxAdded) {
      if (greaterImpact < body.linearVelocity.length2) {
        greaterImpact = body.linearVelocity.length2;
      }

      if (valueToDestroy < body.linearVelocity.length2) {
        world.add(SpriteAnimationComponent(
            position: body.position,
            animation: explotionAnimation.clone(),
            anchor: Anchor.center,
            size: Vector2.all(50),
            removeOnFinish: true));

        removeFromParent();
      }
    }
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    add(BoxComponent());

    final spriteImageExplotion = await Flame.images.load('explotion.png');
    final spriteSheetExplotion =
        SpriteSheet(image: spriteImageExplotion, srcSize: Vector2(306, 265));

    explotionAnimation = spriteSheetExplotion.createAnimationByLimit(
        xInit: 0, yInit: 0, step: 6, sizeX: 3, stepTime: .06, loop: false);
    return super.onLoad();
  }
}

class BoxComponent extends SpriteComponent {
  BoxComponent() : super(anchor: Anchor.center, size: Vector2.all(4));

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('box.png');
    return super.onLoad();
  }
}

class Box {
  Vector2 position;
  double timeToAdd;

  Box({required this.position, this.timeToAdd = .5});
}

List<Box> getCurrentLevel({int level = 1}) {
  switch (level) {
    case 1:
      return [
        // line 1
        Box(position: Vector2(800, 10)),
        Box(position: Vector2(840, 10)),
        Box(position: Vector2(880, 10)),
        Box(position: Vector2(920, 10)),
        Box(position: Vector2(960, 10)),
        //line 2
        Box(position: Vector2(820, 10)),
        Box(position: Vector2(860, 10)),
        Box(position: Vector2(900, 10)),
        Box(position: Vector2(940, 10)),
        //line 3
        Box(position: Vector2(840, 10)),
        Box(position: Vector2(880, 10)),
        Box(position: Vector2(920, 10)),
        //line 3
        Box(position: Vector2(860, 10)),
        Box(position: Vector2(900, 10)),
        //line 4
        Box(position: Vector2(880, 10))
      ];
    default:
      return [];
  }
}
