part of crowdy;

Application app;

svg.SvgSvgElement canvas;

Map<String, Operator> operators;
String currentOperatorId;
BaseOperatorUI selectedOperator;

PortUI selectedPort;
svg.LineElement tempLine;

html.Element _dragSource;
int opNumber = 1;

bool isFirefox = html.window.navigator.userAgent.contains("Firefox");