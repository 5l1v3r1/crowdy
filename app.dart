library crowdy;

import 'dart:async';
import 'dart:html' as html;
import 'dart:svg' as svg;
import 'package:logging/logging.dart';

part 'constants.dart';
part 'ui/PortUI.dart';
part 'ui/FlowLineUI.dart';
part 'ui/OperatorUI.dart';
part 'ui/OperatorDetailsUI.dart';
part 'ui/ApplicationUI.dart';

part 'logic/Operator.dart';
part 'logic/OutputSpecification.dart';
part 'logic/Application.dart';

void main() {
  Application app = new Application("#app_container");

  var messageList = html.document.querySelector('div#bottom-panes div#messages ul');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
    var newMessage = new html.LIElement();
    newMessage.text = rec.message;
    messageList.children.insert(0, newMessage);
    html.document.querySelector('ul#bottom-tabs li a span#count').text = '${messageList.children.length}';
    if (rec.loggerName == 'OperatorDetails') {
      modalAlert.style.display = 'block';
      modalAlert.querySelector('span.message').text = rec.message;
    }
  });
}