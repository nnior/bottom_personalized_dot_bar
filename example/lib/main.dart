import 'package:bottom_personalized_dot_bar/bottom_personalized_dot_bar.dart';
import 'package:flutter/material.dart';

import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _itemSelected = 'item-1';
  bool _enableAnimation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchOutCurve: Interval(0.0, 0.0),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final revealAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.ease));
              return AnimatedBuilder(
                builder: (BuildContext context, Widget _) {
                  return _buildAnimation(context, _itemSelected, child, revealAnimation.value);
                },
                animation: animation,
              );
            },
            child: _buildPage(_itemSelected),
          ),
          BottomPersonalizedDotBar(
              width: (MediaQuery.of(context).size.width > 600) ? 500.0 : null,
              keyItemSelected: _itemSelected,
              doneText: 'Done',
              settingTitleText: 'Your Menu',
              settingSubTitleText: 'Drag and drop',
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10.0, spreadRadius: 1.0)
              ],
              iconSettingColor: const Color(0xFFFFD201),
              buttonDoneColor: const Color(0xFFFFD500),
              settingSubTitleColor: const Color(0xFFFECE02),
              hiddenItems: <BottomPersonalizedDotBarItem>[
                BottomPersonalizedDotBarItem('item-4',
                    icon: Icons.cloud, name: 'Nube', onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-5',
                    icon: Icons.access_alarm, name: 'Alarma', onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-6',
                    icon: Icons.message, name: 'Mensaje', onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-7',
                    icon: Icons.notifications, name: 'Alerta', onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-8',
                    icon: Icons.security, name: 'Seguridad', onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-9',
                    icon: Icons.help, name: 'Ayuda', onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-10',
                    icon: Icons.settings, name: 'Config.', onTap: (itemSelected) => _changePage(itemSelected)),
              ],
              items: <BottomPersonalizedDotBarItem>[
                BottomPersonalizedDotBarItem('item-1',
                    icon: Icons.sentiment_very_satisfied,
                    name: 'Flutter',
                    onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-2',
                    icon: Icons.favorite_border,
                    name: 'Favorito',
                    onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('item-3',
                    icon: Icons.face,
                    name: 'Perfil',
                    onTap: (itemSelected) => _changePage(itemSelected)),
              ]),
        ],
      ),
    );
  }

  void _changePage(String itemSelected) {
    if (_itemSelected != itemSelected && _enableAnimation){
      _enableAnimation = false;
      setState(() => _itemSelected = itemSelected);
      Future.delayed(const Duration(milliseconds: 700), () => _enableAnimation = true);
    }
  }

  Widget _buildAnimation(BuildContext context ,String itemSelected, Widget child, double valueAnimation){
    switch (itemSelected) {
      case 'item-1':
        return Transform.translate(offset: Offset(.0, -(valueAnimation - 1).abs() * MediaQuery.of(context).size.width), child: child);
      case 'item-2':
        return PageReveal(revealPercent: valueAnimation, child: child);
      case 'item-3':
        return Opacity(opacity: valueAnimation, child: child);
      case 'item-4':
        return Transform.translate(offset: Offset(-(valueAnimation - 1).abs() * MediaQuery.of(context).size.width, .0), child: child);
      case 'item-5':
        return Transform.translate(offset: Offset((valueAnimation - 1).abs() * MediaQuery.of(context).size.width, .0), child: child);
      case 'item-6':
        return Transform.translate(offset: Offset(.0, (valueAnimation - 1).abs() * MediaQuery.of(context).size.width), child: child);
      case 'item-7':
        return Transform.scale(scale: valueAnimation, child: child);
      case 'item-8':
        return PageReveal(revealPercent: valueAnimation, child: child);
      case 'item-9':
        return Transform.translate(offset: Offset(.0, -(valueAnimation - 1).abs() * MediaQuery.of(context).size.width), child: child);
      case 'item-10':
        return Transform.translate(offset: Offset((valueAnimation - 1).abs() * MediaQuery.of(context).size.width, .0), child: child);
      default:
        return Transform.translate(offset: Offset(.0, -(valueAnimation - 1).abs() * MediaQuery.of(context).size.width), child: child);
    }
  }

  Widget _buildPage(String itemSelected){
    switch (itemSelected) {
      case 'item-1':
        return FlutterPage(key: UniqueKey(),
            title: 'THE DART SIDE!',
            urlAsset: 'assets/dash-logo.png',
            backgroundColor: const Color(0xFFFFD107));
      case 'item-2':
        return FlutterPage(key: UniqueKey(),
            title: 'FAVORITOS',
            urlAsset: 'assets/flutter-img-1.png',
            backgroundColor: const Color(0xFF4DB6AC));
      case 'item-3':
        return FlutterPage(key: UniqueKey(),
            title: 'PERFIL',
            urlAsset: 'assets/flutter-img-2.png',
            backgroundColor: const Color(0xFFF9A825));
      case 'item-4':
        return FlutterPage(key: UniqueKey(),
            title: 'NUBE',
            urlAsset: 'assets/flutter-img-3.png',
            backgroundColor: const Color(0xFF26C6DA));
      case 'item-5':
        return FlutterPage(key: UniqueKey(),
            title: 'ALARMA',
            urlAsset: 'assets/flutter-img-4.png',
            backgroundColor: const Color(0xFFCDDC39));
      case 'item-6':
        return FlutterPage(key: UniqueKey(),
            title: 'MENSAJE',
            urlAsset: 'assets/flutter-img-5.png',
            backgroundColor: const Color(0xFF66BB6A));
      case 'item-7':
        return FlutterPage(key: UniqueKey(),
            title: 'ALERTA',
            urlAsset: 'assets/flutter-img-6.png',
            backgroundColor: const Color(0xFFFB8C00));
      case 'item-8':
        return FlutterPage(key: UniqueKey(),
            title: 'SEGURIDAD',
            urlAsset: 'assets/flutter-img-7.png',
            backgroundColor: const Color(0xFFA1887F));
      case 'item-9':
        return FlutterPage(key: UniqueKey(),
            title: 'AYUDA',
            urlAsset: 'assets/flutter-img-8.png',
            backgroundColor: const Color(0xFFEF5350));
      case 'item-10':
        return FlutterPage(key: UniqueKey(),
            title: 'CONFIGURACION',
            urlAsset: 'assets/flutter-img-9.png',
            backgroundColor: const Color(0xFF9575CD));
      default:
        return FlutterPage(key: UniqueKey(), backgroundColor: Colors.white);
    }
  }

}

class FlutterPage extends StatelessWidget {

  final Color backgroundColor;
  final String urlAsset;
  final String title;

  const FlutterPage({Key key, this.backgroundColor, this.urlAsset, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: 120.0),
      child: Column(
        children: <Widget>[
          Text(title, style: TextStyle(
            color: const Color(0xBB000000),
            fontSize: 35.0,
            fontWeight: FontWeight.w700,
          )),
          Expanded(child: Image.asset(urlAsset, fit: BoxFit.contain)),
        ],
      ),
    );
  }
}


class PageReveal extends StatelessWidget {
  final double revealPercent;
  final Widget child;

  const PageReveal({Key key, this.revealPercent, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: CircleRevealClipper(revealPercent),
      child: child,
    );
  }
}

class CircleRevealClipper extends CustomClipper<Rect> {
  final double revealPercent;

  CircleRevealClipper(this.revealPercent);

  @override
  Rect getClip(Size size) {
    final epicenter = Offset(size.width / 2, size.height * 0.5);
    double theta = atan(epicenter.dy / epicenter.dx);
    final distanceToCorner = epicenter.dy / sin(theta);

    final radius = distanceToCorner * revealPercent;

    final diameter = 2 * radius;

    return Rect.fromLTWH(
        epicenter.dx - radius, epicenter.dy - radius, diameter, diameter);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}