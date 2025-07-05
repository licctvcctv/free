
const double projectScreenWidth = 360;
const double projectScreenHeight = 800;

var realScreenWidth = 1.0;
var realScreenHeight = 1.0;

var widthRadio = 1.0;
var heightRadio = 1.0;

setRealScreenSize(double width, double height){
  realScreenWidth = width;
  realScreenHeight = height;

  widthRadio = realScreenWidth / projectScreenWidth;
  heightRadio = realScreenWidth / projectScreenHeight;
}

extension ScreenResize on double{
  double get h => (this * heightRadio);
  double get w => (this * widthRadio);
}
