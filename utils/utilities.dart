part of crowdy;

/*
 * String helpers
 */
List<String> delimit(String text, String delimiter) {
  List<String> result = new List<String>();

  if (text.isEmpty || delimiter.isEmpty) {
    result.add('');
  }
  else {
    for (String portion in text.trim().split(delimiter)) {
      if (portion.trim().isNotEmpty) {
        result.add(portion);
      }
    }
  }

  return result;
}

/*
 * Event helpers
 */
dynamic getMouseCoordinatesRelativeToCanvas(html.MouseEvent e) {
  return {
    'x': (e.client.x - canvas.getScreenCtm().e),
    'y': (e.client.y - canvas.getScreenCtm().f)
  };
}

dynamic getRelativeMouseCoordinates(html.MouseEvent e) {
  return {
    'x': (e.offset.x),
    'y': (e.offset.y)
  };
}

dynamic getMouseCoordinatesProportinalToCanvas(html.MouseEvent e) {
  return {
    'x': (e.client.x - canvas.currentTranslate.x)/canvas.currentScale,
    'y': (e.client.y - canvas.currentTranslate.y)/canvas.currentScale
  };
}

void _editableKeyPressed(html.KeyboardEvent e, bool editable) {
  html.SpanElement target = e.target;

  if((target.text.length <= 4) ||
      !isBackspacePressed(e) && (!(isAlphaNumericPressed(e) || isDashPressed(e)) || (target.text.length > 31))) {
    e.preventDefault();
  }
}

void _tabbableTextAreaKeyPressed(html.KeyboardEvent e) {
  if (e.keyCode == 9) {
    e.preventDefault();

    html.TextAreaElement textArea = e.target as html.TextAreaElement;
    String currentValue = textArea.value;
    int start = textArea.selectionStart;
    int end = textArea.selectionEnd;

    textArea.value = currentValue.substring(0, start) + "\t" + currentValue.substring(end);
  }
}

void _triggerDetails(html.DivElement div) {
  if (div.className.contains('hide')) {
    div.className = 'inner';
  }
  else {
    div.className = 'inner hide';
  }
}

bool isFirefox = html.window.navigator.userAgent.contains("Firefox");
bool isIE = html.window.navigator.userAgent.contains("Microsoft");

bool isModalActive = html.document.querySelector(".modal").style.display == 'block';

int getCharCode(html.KeyboardEvent e) {
  return e.charCode > 0 ? e.charCode : e.keyCode > 0 ? e.keyCode : e.which > 0 ? e.which : 0;
}

bool isAlphaNumericPressed(html.KeyboardEvent e) {
  int charCode = getCharCode(e);
  return charCode > 31 &&
      ((charCode >= 48 && charCode <= 57) ||
          (charCode >= 65 && charCode <= 90) ||
          (charCode >= 97 && charCode <= 122));
}

bool isDashPressed(html.KeyboardEvent e) {
  return e.keyCode == 189 || (isFirefox && e.keyCode == 173);
}

bool isBackspacePressed(html.KeyboardEvent e) {
  return e.keyCode == 8 || e.keyCode == 46;
}


/*
 * Report a bug
 */
String logMessages = "";
void report(html.MouseEvent e) {
  appendToUtilityModalBody(new html.DivElement()
    ..className = 'row'
    ..append(new html.LabelElement()..className = 'col-sm-3 control-label'..text = 'Message')
    ..append(new html.DivElement()..className = 'col-sm-9'
      ..append(new html.TextAreaElement()..id = 'report_1'..className = 'form-control'..rows = 5)));

  appendToUtilityModalBody(new html.DivElement()
      ..className = 'row'
      ..append(new html.LabelElement()..className = 'col-sm-3 control-label'..text = 'Log')
      ..append(new html.DivElement()..className = 'col-sm-9'
        ..append(new html.TextAreaElement()..id = 'report_2'..className = 'form-control'..rows = 5..disabled = true..text = logMessages)));

  appendToUtilityModalBody(new html.DivElement()
      ..className = 'row'
      ..append(new html.DivElement()..className = 'col-sm-12'
        ..append(new html.ParagraphElement()..id = 'report_3')));

  appendToUtilityModalFooter(new html.ButtonElement()..className = 'btn btn-default'..text = 'Send'..onClick.listen((e) => reportBug()));

  showUtilityModal('Report Bug');
}

void reportBug() {
  var url = "/report";
  Map<String, String> pairs = new Map<String, String>();
  pairs["message"] = (utilityModalBody.querySelector('#report_1') as html.TextAreaElement).value;
  pairs["log"] = utilityModalBody.querySelector('#report_2').text;

  try {
    postData(url, pairs, utilityModalBody.querySelector('#report_3'));
  }
  catch(e) {
    utilityModalBody.querySelector('#report_3').text = e.toString();
  }
}

/*
 * Utility modal operations
 */
void showUtilityModal(String title, {String message, bool closeButton: true}) {
  utilityModal.onClick.listen((e) { if (e.target == utilityModal) { hideUtilityModal(); }});
  utilityModal.classes.add('in');
  utilityModal.style.display = 'block';

  if (message != null) {
    utilityModalWarning.style.display = 'block';
    utilityModalWarning.querySelector('span.message').text = message;
    utilityModalWarning.querySelector('.close').onClick.listen((e) => utilityModalWarning.style.display = 'none');
  }

  utilityModalHeader.querySelector('h4').text = title;

  if (closeButton) {
    utilityModalFooter.append(
        new html.ButtonElement()
        ..className = 'btn btn-default'
        ..text = 'Close'
        ..onClick.listen((e) => hideUtilityModal()));
  }
}

void appendToUtilityModalBody(html.Element element) {
  utilityModalBody.append(element);
}

void appendToUtilityModalFooter(html.Element element) {
  utilityModalFooter.append(element);
}

void hideUtilityModal() {
  utilityModalWarning.style.display = 'none';
  utilityModalBody.children.clear();
  utilityModalFooter.children.clear();
  utilityModal.style.display = 'none';
}

/*
 * HTTP helpers
 */
void postData(String url, Map<String, String> pairs, html.Element result) {
  html.HttpRequest request = new html.HttpRequest();

  request.onReadyStateChange.listen((e) {
    if (request.readyState == html.HttpRequest.DONE && (request.status == 200 || request.status == 0)) {
      result.text = request.responseText;
    }
  });

  // POST the data to the server
  request.open("POST", url, async: false);

  String jsonData = '{';
  pairs.forEach((key, value) => jsonData += '"$key": "${value.replaceAll('"', '')}", ');
  jsonData += '"test": "mert"}';
  request.send(jsonData);
}