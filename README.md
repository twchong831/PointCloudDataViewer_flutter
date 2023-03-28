# PointCloudData Viewer

My first Flutter application was done!
This Flutter project is for Point Cloud Data(PCD) Visualizer.

## Point Cloud Data file format

- [point cloud library](https://pointclouds.org/)
- [PCD format](https://pointclouds.org/documentation/tutorials/pcd_file_format.html)
  - only ASCii
  - XYZ
  - XYZRGB

## used package list

1. [ditredi](https://pub.dev/packages/ditredi)
   1. [vector_math](https://pub.dev/packages/vector_math)
2. [file_picker](https://pub.dev/packages/file_picker)
3. [path_provider](https://pub.dev/packages/path_provider)
4. [sidebarx](https://pub.dev/packages/sidebarx)
5. [tab_container](https://pub.dev/packages/tab_container)
6. [flutter_colorpicker](https://pub.dev/packages/flutter_colorpicker)

## Rebuild

```bash
flutter clean project
flutter pub get
```

## result

- in Mac OS

### File Select

<img src="./image/fileSelect.gif" width="50%" heigth="50%">

### Basic Visualization

<img src="./image/visual_basic.gif" width="50%" heigth="50%">

#### Play PCD Files

<img src="./image/visual_play.gif" width="50%" heigth="50%">

### Point Size

<img src="./image/pointSize_change.gif" width="50%" heigth="50%">

### Change Viewer Configuration

#### Grid & Point Size

<img src="./image/grid.gif" width="50%" heigth="50%">

<img src="./image/gird_point_size.gif" width="50%" heigth="50%">

#### Background Color

<img src="./image/backgroundColor.gif" width="50%" heigth="50%">
