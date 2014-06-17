library crowdy;

import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:svg' as svg;
import 'package:logging/logging.dart';

part 'utils/constants.dart';
part 'utils/utilities.dart';
part 'utils/Validation.dart';

part 'application/Application.dart';
part 'application/FlowLine.dart';
part 'application/Operator.dart';
part 'application/OperatorBody.dart';
part 'application/OperatorDetails.dart';
part 'application/OutputSpecification.dart';
part 'application/Port.dart';

final Logger log = new Logger('crowdy');

Application app;

void main() {
  app = new Application("#app_container");

  var messageList = html.document.querySelector('div#bottom-panes div#messages ul');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    String message = "${rec.level.name}: ${rec.time}: ${rec.message}";
    print(message);

    // Append log messages for bug reporting
    logMessages += "${message}\n";

    if (rec.level.value > 800) {
      var newMessage = new html.LIElement();
      newMessage.text = rec.message;
      messageList.children.insert(0, newMessage);
      html.document.querySelector('ul#bottom-tabs li a span#count').text = '${messageList.children.length}';
      if (modal.style.display == 'block') {
        modalAlert.style.display = 'block';
        modalAlert.querySelector('span.message').text = rec.message;
      }
    }
  });

  html.document.querySelector('#validate').onClick.listen(validate);
  html.document.querySelector('#clear').onClick.listen(clear);
  html.document.querySelector('#report').onClick.listen(report);
  html.document.querySelector('#sample').onClick.listen(sample);
  html.document.onKeyDown.listen(_onKeyDown);
}

void validate(html.MouseEvent e) {
  validation.start();
}

void clear(html.MouseEvent e) {
  operators.forEach((id, operator) => operator.body.remove());
  operators.clear();

  opNumber = 1;
  logMessages = "";
}

void sample(html.MouseEvent e) {
  String operatorId = 'operator_1';
  operators[operatorId] = app.addOperator(operatorId, 'source.manual', 100, 100);
  var details = operators[operatorId].uiDetails as SourceManualDetails;
  details.base['name'].input.value = 'Read Operator';
  details.base['description'].input.value = 'This operator will read the manual entry. The content will be parsed with respect to the following parameters. This will basically result in a data flow with a number of data segments.';
  details.elements['input'].input.value = 'Brazil, Mexico, Cameroon, Crotia\nNetherlands, Chile, Australia, Spain\nColombia, Ivory Coast, Japan, Greece\nCosta Rica, Italy, England, Uruguay\nFrance, Switzerland, Ecuador, Honduras\nArgentina, Iran, Nigeria, Bosnia\nGermany, United States, Ghana, Portugal\nBelgium, Algeria, Russia, South Korea';
  details.elements['delimiter'].input.value = '3';
  details._onRefresh();

  operatorId = 'operator_2';
  operators[operatorId] = app.addOperator(operatorId, 'processing.human', 300, 100);
  details = operators[operatorId].uiDetails as HumanDetails;
  details.base['name'].input.value = 'Human Processing Operator';
  details.base['description'].input.value = 'This operator will receive the data segments from previous operator. These segments can be used to configure the human task.';
  details.elements['instructions'].input.innerHtml = 'Please read the question below and answer the question.';
  details.elements['question'].input.innerHtml = 'Select the teams that you think it will qualify to the next round.';

  operatorId = 'operator_3';
  operators[operatorId] = app.addOperator(operatorId, 'sink.email', 500, 100);
  details = operators[operatorId].uiDetails as SinkEmailDetails;
  details.base['name'].input.value = 'Write Operator';
  details.base['description'].input.value = 'This operator will write the results into a file. This file will be available to download.';
  details.elements['email'].input.value = 'mertk-test@outlook.com';

  var op1 = operators['operator_1'] as SourceManualOperator;
  var op2 = operators['operator_2'] as HumanProcessingOperator;
  var op3 = operators['operator_3'] as SinkEmailOperator;
  canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_DRAW, detail: [op1.body.outputPort, op2.body.inputPort]));
  canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_DRAW, detail: [op2.body.outputPort, op3.body.inputPort]));
}

void _onKeyDown(html.KeyboardEvent e) {
  if (e.target is html.BodyElement && isBackspacePressed(e) && !isModalActive) {
    e.preventDefault();

    if (selectedFlow != null) {
      selectedFlow.remove();
      selectedFlow = null;
    }

    if (selectedOperator != null) {
      String operatorId = selectedOperator.id;
      canvas.dispatchEvent(new html.CustomEvent(OPERATOR_UNIT_REMOVE, detail: operatorId));
      selectedOperator.remove();
      operators.remove(operatorId);
      log.info("Operator ${operatorId} is removed.");
    }
  }
}