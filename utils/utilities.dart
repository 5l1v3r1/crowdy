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

  if(!isBackspacePressed(e) && (!(isAlphaNumericPressed(e) || isDashPressed(e)) || (target.text.length > 31))) {
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
  return e.keyCode == 109 || e.keyCode == 189;
}

bool isBackspacePressed(html.KeyboardEvent e) {
  return e.keyCode == 8 || e.keyCode == 45;
}


/*
 * Report a bug
 */
String logMessages = "";
void report(html.MouseEvent e) {
  reportModal.classes.add('in');
  reportModal.style.display = 'block';

  reportModalBody.querySelector('#report_2').text = logMessages;

  closeReportButton.onClick.listen((e) {
    reportModal.style.display = 'none';
    (reportModalBody.querySelector('#report_3') as html.ParagraphElement).text = "";
  });
  sendReportButton.onClick.listen((e) => reportBug());
}

void reportBug() {
  var url = "/report";
  url += "/${Uri.encodeQueryComponent((reportModalBody.querySelector('#report_1') as html.TextAreaElement).value)}";
  url += "/${Uri.encodeQueryComponent(reportModalBody.querySelector('#report_2').text)}";

  try {
    html.HttpRequest.getString(url).then((response) {
      reportModalBody.querySelector('#report_3').text = response;
      if (response == "success") {
        html.document.querySelector('#clear').click();
        (reportModalBody.querySelector('#report_1') as html.TextAreaElement).value = "";
        (reportModalBody.querySelector('#report_2') as html.TextAreaElement).value = "";
      }
    });
  }
  catch(e) {
    reportModalBody.querySelector('#report_3').text = e.toString();
  }
}