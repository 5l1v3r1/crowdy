part of crowdy;

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
  int charCode = e.charCode > 0 ? e.charCode : e.keyCode > 0 ? e.keyCode : e.which > 0 ? e.which : 0;
  bool isAlphaNumeric = charCode > 31 &&
      ((charCode >= 48 && charCode <= 57) ||
          (charCode >= 65 && charCode <= 90) ||
          (charCode >= 97 && charCode <= 122));
  bool isMinus = e.keyCode == 109 || e.keyCode == 189;
  bool isBackspace = e.keyCode == 8;
  if(!isBackspace && (!(isAlphaNumeric || isMinus) || (target.text.length > 31))) {
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


/*
 * Report a bug
 */
String logMessages = "";
void report(html.MouseEvent e) {
  reportModal.classes.add('in');
  reportModal.style.display = 'block';

  reportModalBody.querySelector('#report_2').text = logMessages;

  closeReportButton.onClick.listen((e) => reportModal.style.display = 'none');
  sendReportButton.onClick.listen((e) => reportBug());
}

void reportBug() {
  var url = "/report";
  html.HttpRequest request = new html.HttpRequest();
  request.open("POST", url, async: false);

  String data = "message=${Uri.encodeQueryComponent((reportModalBody.querySelector('#report_1') as html.TextAreaElement).value)}";
  data += "&log=${Uri.encodeQueryComponent(reportModalBody.querySelector('#report_2').text)}";
  reportModalBody.querySelector('#report_3').text = data;

  try {
    request.send(data);
  }
  catch(e) {
    reportModalBody.querySelector('#report_3').text = e.toString();
  }
}