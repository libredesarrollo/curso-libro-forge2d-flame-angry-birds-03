import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:angry03/components/player_body.dart';
import 'package:angry03/utils/boundaries.dart';

import 'package:angry03/components/box.dart' as box;

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame with TapCallbacks {
  MyGame() : super(gravity: Vector2(0, 40), zoom: 10);

  PlayerBody? playerBody;

  // levels
  final int _currentLevel = 1;
  double _boxTime = 0.0;
  int _boxIndex = 0;

  bool boxsAdded = false;

  double _totalBoxImpact = 0;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Solo añadimos los límites si el mundo está vacío de muros y el tamaño es válido
    if (size.x > 0 && world.children.query<Wall>().isEmpty) {
      world.addAll(createBoundaries(this));
    }
  }

  @override
  void update(double dt) {
    _addBoxs(dt);
    if (world.children.query<box.BoxBody>().length ==
            box.getCurrentLevel(level: _currentLevel).length &&
        !boxsAdded) {
      // all boxes have been added in the world
      if (world.children
          .query<box.BoxBody>()
          .where((b) => !b.boxAdded)
          .isEmpty) {
        // all boxes have been placed (rest) in the world
        boxsAdded = true;
      }
    }

    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!boxsAdded) {
      return;
    }

    if (playerBody == null || playerBody!.isRemoved) {
      playerBody = PlayerBody(
          position: screenToWorld(event.localPosition),
          parentFunctionOnRemove: totalBoxImpact);
      world.add(playerBody!);
    }
  }

  totalBoxImpact() {
    world.children.query<box.BoxBody>().forEach((b) {
      _totalBoxImpact = b.greaterImpact;
    });
    debugPrint(_totalBoxImpact.toString());
  }

  _addBoxs(double dt) {
    // add boxs to world
    if (_boxIndex < box.getCurrentLevel(level: _currentLevel).length) {
      if (_boxTime >=
          box.getCurrentLevel(level: _currentLevel)[_boxIndex].timeToAdd) {
        final boxBody = box.BoxBody(
            position: screenToWorld(
                box.getCurrentLevel(level: _currentLevel)[_boxIndex].position));
        world.add(boxBody);
        _boxIndex++;
        _boxTime = 0;
      }
      _boxTime += dt;
    } else {
      // all boxes have been added
      //boxsAdded = true;
    }
  }
}
