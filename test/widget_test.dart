// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coercion', () {
    void myCallback([num? value]) {
      print(value);
    }

    final container = CallbackContainer(myCallback);

    final doIt = container.coerce<int>();

    doIt?.call(1);
  });
  testWidgets('inherited function', (WidgetTester tester) async {
    final app = MaterialApp(
      home: InheritedFunction<AObject>(
        callback: ([value]) {},
        child: InheritedFunction<bool>(
          callback: ([value]) {},
          child: Builder(
            builder: (context) {
              final callback = InheritedFunction.of<BObject>(context);
              print(callback);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(app);
  });
}

class AObject {
  const AObject(this.tag);

  final String tag;
}

class BObject extends AObject {
  const BObject(super.tag);
}

typedef Callback<T> = void Function([T? value]);

class CallbackContainer<T> {
  const CallbackContainer(this.callback);

  final Callback<T> callback;

  Callback<R>? coerce<R>() {
    if (callback is! Callback<R>) {
      return null;
    }
    return callback as Callback<R>;
  }
}

class InheritedFunction<T> extends StatefulWidget {
  const InheritedFunction({
    required this.callback,
    required this.child,
    super.key,
  });

  final Callback<T> callback;

  final Widget child;

  @override
  State<InheritedFunction> createState() => _InheritedFunctionState<T>();

  static Callback<T>? of<T>(BuildContext context) {
    var element =
        context.getElementForInheritedWidgetOfExactType<_InheritedFunction>();
    var state = element?.findAncestorStateOfType<_InheritedFunctionState>();
    var container = state?.container;

    Callback<T>? onResult;

    while (state != null &&
        container is! CallbackContainer<T> &&
        onResult == null) {
      element = state.context
          .getElementForInheritedWidgetOfExactType<_InheritedFunction>();
      state = element?.findAncestorStateOfType<_InheritedFunctionState>();
      container = state?.container;
      onResult = container?.coerce<T>();
    }

    if (onResult != null) {
      print('Gotcha bitch! $T');
    }

    return onResult;
  }
}

class _InheritedFunctionState<T> extends State<InheritedFunction<T>> {
  late final CallbackContainer<T> container;

  @override
  void initState() {
    super.initState();
    container = CallbackContainer(widget.callback);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedFunction(
      child: widget.child,
    );
  }
}

class _InheritedFunction extends InheritedWidget {
  const _InheritedFunction({required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
