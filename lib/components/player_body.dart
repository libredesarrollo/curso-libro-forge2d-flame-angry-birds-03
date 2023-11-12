import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

import 'package:forge2d/src/dynamics/body.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:angry03/utils/create_animation_by_limit.dart';

class PlayerBody extends BodyComponent with DragCallbacks {
  final double maxDistance = 15.0;
  final double maxDistance2 = 225.0;

  Vector2 position;
  late Vector2 originalPosition;
  Function parentFunctionOnRemove;

  bool _throwPlayer = false;
  double _elapseTimeToRemove = 0;
  final double _timeToRemove = 10;

  // sprite
  late PlayerComponent _playerComponent;

  PlayerBody({required this.position, required this.parentFunctionOnRemove})
      : super() {
    originalPosition = position;
    renderBody = true;
  }

  @override
  Future<void> onLoad() {
    _playerComponent = PlayerComponent();
    add(_playerComponent);
    return super.onLoad();
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 2;
    final bodyDef = BodyDef(position: position, type: BodyType.kinematic);
    final fixtureDef =
        FixtureDef(shape, friction: 1, density: 5, restitution: 0);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final distancePositions =
        (game.screenToWorld(event.canvasPosition) - originalPosition).length2;
    if (distancePositions < maxDistance2) {
      body.setTransform(game.screenToWorld(event.canvasPosition), 0);
    } else {
      // range out
      body.setTransform(
          originalPosition +
              (game.screenToWorld(event.canvasPosition) - originalPosition)
                      .normalized() *
                  maxDistance,
          0);
    }
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    body.setType(BodyType.dynamic);
    body.applyForce((originalPosition - body.position) * 80000);

    _throwPlayer = true;

    _playerComponent.animation = _playerComponent.flyAnimation;

    super.onDragEnd(event);
  }

  @override
  void update(double dt) {
    // al momento de lanzar al player
    if (_throwPlayer) {
      if (_elapseTimeToRemove < _timeToRemove) {
        _elapseTimeToRemove += dt;
      } else {
        removeFromParent();
        parentFunctionOnRemove();
      }
    }

    super.update(dt);
  }
}

class PlayerComponent extends SpriteAnimationComponent {
  late SpriteAnimation idleAnimation, flyAnimation;

  PlayerComponent() : super(anchor: Anchor.center, size: Vector2.all(10)) {
    anchor = anchor;
    size = size;
  }

  @override
  FutureOr<void> onLoad() async {
    final spriteImage = await Flame.images.load('birds.png');
    final spriteSheet =
        SpriteSheet(image: spriteImage, srcSize: Vector2.all(125));

    // init animation
    idleAnimation = spriteSheet.createAnimationByLimit(
        xInit: 0, yInit: 0, step: 3, sizeX: 3, stepTime: .08);

    flyAnimation = spriteSheet.createAnimationByLimit(
        xInit: 1, yInit: 0, step: 3, sizeX: 3, stepTime: .08);

    animation = idleAnimation;

    return super.onLoad();
  }
}
