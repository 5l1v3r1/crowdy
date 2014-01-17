library crowdy;

import 'dart:async';
import 'dart:html' as html;
import 'dart:svg' as svg;
import 'package:logging/logging.dart';

part 'constants.dart';
part 'utilities.dart';

part 'ui/PortUI.dart';
part 'ui/FlowLineUI.dart';
part 'ui/OperatorUI.dart';
part 'ui/OperatorDetailsUI.dart';
part 'ui/ApplicationUI.dart';

part 'logic/Operator.dart';
part 'logic/OutputSpecification.dart';
part 'logic/Application.dart';

Application app;

void main() {
  app = new Application("#app_container");

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

  html.document.querySelector('#translationExample').onClick.listen(translationExample);
}

void translationExample(html.MouseEvent e) {
  operators.forEach((id, operator) => operator.ui.remove());

  String operatorId = 'operator_1';
  operators[operatorId] = app.addOperator(operatorId, 'source.manual', 100, 100);
  operators[operatorId].initialize();
  var details = operators[operatorId].details as SourceManualDetailsUI;
  details.base['name'].input.value = 'Read Operator';
  details.base['description'].input.value = 'This operator will read the manual entry. The content will be parsed with respect to the following parameters. This will basically result in a data flow with a number of data segments.';
  details.elements['input'].input.value = 'line-1-segment-1 line-1-segment-2\nline-2-segment-1 line-2-segment-2';
  details.elements['delimiter'].input.value = '1';
  details._onRefresh();

  operatorId = 'operator_2';
  operators[operatorId] = app.addOperator(operatorId, 'processing.human', 300, 100);
  operators[operatorId].initialize();
  details = operators[operatorId].details as SourceHumanDetailsUI;
  details.base['name'].input.value = 'Human Processing Operator';
  details.base['description'].input.value = 'This operator will receive the data segments from previous operator. These segments can be used to configure the human task.';

  operatorId = 'operator_3';
  operators[operatorId] = app.addOperator(operatorId, 'sink.file', 500, 100);
  operators[operatorId].initialize();
  details = operators[operatorId].details as SinkFileDetailsUI;
  details.base['name'].input.value = 'Write Operator';
  details.base['description'].input.value = 'This operator will write the results into a file. This file will be available to download.';

  canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_DRAW, detail: [operators['operator_1'].ui.outputPort, operators['operator_2'].ui.inputPort]));
  canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_DRAW, detail: [operators['operator_2'].ui.outputPort, operators['operator_3'].ui.inputPort]));
}