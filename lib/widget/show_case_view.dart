import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:jackdigitalstore_app/provider/home_provider.dart';
import 'package:jackdigitalstore_app/session/session.dart';
import 'package:jackdigitalstore_app/utils/shared.dart';
import 'package:jackdigitalstore_app/widget/custom_shape.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:math' as math;

class ShowCaseView extends StatelessWidget {
  const ShowCaseView(
      {Key? key,
      required this.globalKey,
      required this.child,
      this.shapeBorder = const CircleBorder(),
      required this.description,
      required this.index})
      : super(key: key);

  final GlobalKey globalKey;
  final Widget child;
  final String description;
  final ShapeBorder shapeBorder;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: globalKey,
      child: child,
      disableMovingAnimation: true,
      container: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 10,
          ),
          Visibility(
            visible: index == 1 || index == 2,
            child: Row(children: [
              Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: CustomPaint(
                      painter:
                          CustomShape(Colors.white, 10, 0, 0, -15, -10, 0))),
              Container(
                width: index == 1 ? 50 : 20,
              )
            ]),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        Provider.of<HomeProvider>(context, listen: false)
                            .imageGuide),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white),
            child: Column(
              children: [
                Image.asset('assets/images/hi_icon.png', height: 50, width: 50),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    description,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 3,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    ShowCaseWidget.of(context).next();
                    if (index == 2) {
                      Session.data.setBool('tool_tip', false);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HexColor("fa964b"),
                            HexColor("ff3e78"),
                          ],
                        )),
                    child: Text(
                      index == 2
                          ? AppLocalizations.of(context)!
                              .translate("go_shopping")!
                          : AppLocalizations.of(context)!.translate("next")!,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: index == 0,
            child: Row(children: [
              Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: CustomPaint(
                      painter:
                          CustomShape(Colors.white, -10, 0, 0, 15, 10, 0))),
              Container(
                width: 40,
              )
            ]),
          ),
        ],
      ),
      height: 150,
      width: MediaQuery.of(context).size.width * 0.7,
      targetShapeBorder: shapeBorder,
      targetPadding: EdgeInsets.zero,
    );
  }
}
