# flutter_nimplayer

Flutter 版的[网易云信点播](https://doc.yunxin.163.com/vod/docs/home-page)播放器 SDK，支持 Android & iOS。

## 开始使用

添加依赖：

```dart
dependencies:
  flutter_nimplayer: ^0.0.1
```

## 用法

第一步，创建播放器：

```dart
player = FlutterNimplayerFactory.createPlayer();
```

第二步，添加播放器视图：

```dart
NimplayerView(
  onCreated: (viewId) {
    initAndPlay(viewId);
  },
  x: 0,
  y: 0,
  width: viewWidth,
  height: viewHeight,
);
```

第三步，设置播放源并播放：

```dart
void initAndPlay(int viewId) {
  // 建立连接
  player?.setPlayerView(viewId);
  // 设置播放链接
  player?.setUrl(url);
  // 准备播放
  player?.prepare();
}
```

具体示例请移步项目下的 example 文件夹，播放器接口及播放回调请查看项目源码。

欢迎提交 issue 和 PR 帮助完善该项目。

