part of crowdy;

svg.SvgSvgElement canvas;
PortUI selectedPort;
svg.LineElement tempLine;
BaseOperatorUI selectedOperator;

class ApplicationUI {

  final Logger log = new Logger('Application');

  ApplicationUI(String canvas_id) {
    canvas = html.document.querySelector(canvas_id);

    tempLine = new svg.LineElement()
    ..attributes['stroke'] = '#ddd'
    ..attributes['strokeLength'] = '1';

    canvas.append(tempLine);
  }
}