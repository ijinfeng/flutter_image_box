<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

图片九宫格，大图预览组件

## Features

* 支持缩放
* 图片加载提示
* 接口优化

## Getting started

打开`pubspec.yaml`文件，加入依赖：image_box: ^0.0.2

## Usage

### 传入图片url的数组
```dart
ImagesBox.url(
                          urls: imageUrls,
                          fit: BoxFit.cover,
                          format4rect: false,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          padding: const EdgeInsets.all(10),
                          coverBuilder: (context, index, total) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  '$index/$total',
                                  style: TextStyle(color: Colors.white,
                                  fontSize: 20),
                                ),
                              ),
                            );
                          })
```

### 传入组件的方式
```dart
List<Widget> imageWidgets = [];
for (int i = 0; i < min(9, imageUrls.length); i++) {
String imageUrl = imageUrls[i];
Widget image = Image.network(
    imageUrl,
    fit: BoxFit.cover,
);

image = ClipRRect(
    child: image,
    borderRadius: BorderRadius.all(Radius.circular(6)),
);
imageWidgets.add(image);
}

ImagesBox(children: imageWidgets);
```
