import { SongItem } from "../viewmodel/SongItem";
import { displaySync } from "@kit.ArkGraphics2D";
import { PlayerConstants } from "../constant/PlayerConstants";
import { MediaService } from "../utils/MediaService";
import { StyleConstants } from "../constant/Constant";
import { MusicControlComponent } from "./MusicControlComponent";
import { curves, window } from "@kit.ArkUI";
import { Logger } from "../utils/Logger";
import { BusinessError } from "@kit.BasicServicesKit";
import { MediaTools } from "../utils/MediaTools";
import ImageCacheUtils from "../utils/ImageCacheUtils";
import { JSON } from "@kit.ArkTS";

const TAG = 'Player'
/**
 * App界面下方的歌曲播放横栏
 * 用于控制歌曲播放、暂停、下一首
 * 点击可唤起MusicControlComponent，即歌曲播放信息主界面
 */
@Component
export struct Player {
  // 当前正在播放的歌曲index
  @StorageLink('selectIndex') @Watch('updateImage') selectIndex: number = 0;
  // 歌曲是否正在播放
  @StorageLink('isPlay') @Watch('animationFun') isPlay: boolean = false;
  // 全局歌单列表
  @StorageLink('songList') @Watch('updateImage') songList: SongItem[] = [];
  // padding参数
  @StorageLink('topArea') topArea: number = 0;
  @StorageLink('bottomArea') bottomArea: number = 0;
  // 控制是否展现MusicControlComponent界面的变量
  @StorageLink('isShowPlay') isShowPlay: boolean = false;
  // 设备高度，用于动态计算componentHeight
  @StorageLink('deviceHeight') deviceHeight: number = 0;
  // 专辑封面图片旋转角度
  @State imageRotate: number = 0;
  // 用于动态控制MusicControlComponent大小的变量
  @State componentHeight: number = 0;

  @State triggerValueReplace: number = 0;
  // ？可能和歌曲播放控制相关
  private backDisplaySyncSlow: displaySync.DisplaySync | undefined = undefined;

  // 滑动手势事件，当滑动的最小距离达到设定的最小值时触发滑动手势事件。
  // 态修改平移手势识别器的属性，从而避免通过状态变量修改属性（状态变量修改会导致UI刷新）。
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Vertical });

  private drawFrame: (value: displaySync.IntervalInfo) => void = (value: displaySync.IntervalInfo) => {
    if (this.imageRotate >= 360 ) {
      this.imageRotate = 0;
    }
    this.imageRotate += 1;
  };
  private imageCacheUtils: ImageCacheUtils = ImageCacheUtils.getInstance(AppStorage.get('context'));
  @State image: PixelMap | undefined = undefined
  async updateImage() {
    await this.loadImage(this.songList[this.selectIndex].label as string);
  }
  private async loadImage(url: string) {
    try {
      this.image = await MediaTools.getPixelMapFromFile(await this.imageCacheUtils.getCachedImagePath(url));
    } catch (err) {
      Logger.error(TAG, JSON.stringify(url) + 'load image but failed: ' + JSON.stringify(err))
    }
  }
  async aboutToAppear() {
    Logger.info(TAG, 'the url is ' + JSON.stringify(this.songList[this.selectIndex]))
    await this.loadImage(this.songList[this.selectIndex].label as string);
    let range : ExpectedFrameRateRange = {
      expected: 60,
      min: 0,
      max: 120
    };

    this.backDisplaySyncSlow = displaySync.create();
    this.backDisplaySyncSlow.setExpectedFrameRateRange(range);
    this.backDisplaySyncSlow.on('frame', this.drawFrame);
  }

  aboutToDisappear(): void {
    this.backDisplaySyncSlow?.off('frame', this.drawFrame);
  }

  // 控制帧率限制？
  animationFun() {
    if (this.isPlay) {
      this.backDisplaySyncSlow?.start();
    } else {
      this.backDisplaySyncSlow?.stop();
    }
  }

  // musicControlComponent的builder，用于唤起该组件
  @Builder
  musicPlayBuilder() {
    // 双层堆叠，外面一层Column用于控制页面占满屏幕
    Column() {
      // 内部的Column使得组件大小可以根据用户滑动的距离进行缩放，提升用户体验
      Column(){
        MusicControlComponent({ isShowPlay: this.isShowPlay })
      }
      .height((100 - this.componentHeight) + '%')
    }
    .height(StyleConstants.FULL_HEIGHT)
    .width(StyleConstants.FULL_HEIGHT)
    .justifyContent(FlexAlign.End)
    // 组件出场动画，弹性出场，动画时长为1s
    .transition(TransitionEffect.translate({ y: 500 }).animation({ curve: curves.springMotion() }))
    // 沉浸导航条和状态栏配置
    .onAppear(() => {
      window.getLastWindow(getContext(this)).then((windowStage: window.Window) => {
        let area = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.topArea = px2vp(area.topRect.height);
        let bottomArea = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomArea = px2vp(bottomArea.bottomRect.height);
        Logger.info('bottomArea ' + this.bottomArea)
        if (this.topArea > 0) {
          windowStage.setWindowLayoutFullScreen(true);
        }
        let sysBarProps: window.SystemBarProperties = {
          statusBarContentColor: '#FFFFFF'
        };
        windowStage.setWindowSystemBarProperties(sysBarProps);
      }).catch((error: BusinessError) => {
        Logger.error(`${error.code} + ${error.message}`)
      });
    })
    .onDisAppear(() => {
      this.componentHeight = 0;
      this.isShowPlay = false;
      window.getLastWindow(getContext(this)).then((windowStage: window.Window) => {
        let area = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let topHeight = px2vp(area.topRect.height);
        if (topHeight > 0) {
          windowStage.setWindowLayoutFullScreen(false);
        }
        let sysBarProps: window.SystemBarProperties = {
          statusBarContentColor: '#000000'
        };
        windowStage.setWindowSystemBarProperties(sysBarProps);
      }).catch((error: BusinessError) => {
        Logger.error(`${error.code} + ${error.message}`)
      });
    })
    // 处理用户下滑事件：向下滑动可关闭MusicControlComponent，同时组件大小随滑动距离变化
    .gesture(
      PanGesture(this.panOption)
        // 滑动距离变长时
        .onActionUpdate((event?: GestureEvent) => {
          if (event) {
            // 根据用户滑动距离，等比缩放componentHeight
            let height = event?.offsetY / this.deviceHeight * 100
            this.componentHeight = height;
            // 防止滑动过距离
            if (this.componentHeight < 0) {
              this.componentHeight = 0
            }
          }
        })
        .onActionEnd(() => {
          // 如果滑动距离超过40 -> 关闭页面
          if (this.componentHeight > 40) {
            this.isShowPlay = false;
          } else {
            // 否则 重置，什么也没发生
            this.componentHeight = 0;
          }
        })
    )
  }

  private onAvatarClicked(): void {
    this.getUIContext()?.animateTo({
      duration: 1500,
      curve: curves.springMotion()
    }, () => {
      this.isShowPlay = !this.isShowPlay;
    });
  }

  private onMusicPageBack(): void {
    this.getUIContext()?.animateTo({
      duration: 1500,
      curve: curves.springMotion()
    }, () => {
      this.isShowPlay = !this.isShowPlay;
    });
  }
  build() {
    Row() {
      // Player左侧部份
      Row() {
        // 当前正在播放歌曲的专辑
        Image( this.image ? this.image : $r('app.media.ic_dream'))
          .height(32)
          .width(32)
          .margin({ right: 12 })
          // .rotate({ angle: this.imageRotate })
          .onAppear(() => {
            this.animationFun();
          })
            // 对头像绑定共享元素转场的id
          .geometryTransition('songLabel')
          .borderRadius($r('app.float.cover_radius_label'))
          .transition(TransitionEffect.opacity(0.99))
          .onClick(() => {
            this.onAvatarClicked()
          })
        // 歌曲相关信息：歌曲名、歌手
        Column() {
          Text(this.songList[this.selectIndex].title)
            .fontColor(Color.Black)
            .fontSize(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row() {
            Text(this.songList[this.selectIndex].singer)
              .fontColor(Color.Black)
              .fontSize(10)
              .opacity(.38)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }.alignItems(HorizontalAlign.Start).width(200)
      }
      .layoutWeight(PlayerConstants.LAYOUT_WEIGHT_PLAYER_CONTROL)
      .onClick(() => {
        this.onAvatarClicked()
      })

      // 分割左右部份的空白区域
      Blank()
        .onClick(() => {
          this.onAvatarClicked()
        })

      // 右侧部份：前一首歌、播放暂停、下一首歌
      Row() {
        Image($r('app.media.ic_previous'))
          .height($r('app.float.control_icon_height'))
          .width($r('app.float.control_icon_width'))
          .margin({ right: $r('app.float.control_icon_margin') })
          .displayPriority(PlayerConstants.DISPLAY_PRIORITY_TWO)
          .onClick(() => MediaService.getInstance().playPrevious())
        Row() {
          SymbolGlyph(this.isPlay ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
            .fontSize(22)
            .fontColor([$r('app.color.player_icon_color')])
            .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.triggerValueReplace)
            .displayPriority(PlayerConstants.DISPLAY_PRIORITY_THREE)
            .onClick(() => {
              this.triggerValueReplace = this.triggerValueReplace + 1;
              // 如果是第一次播放，播放第一首歌
              if (MediaService.getInstance().getFirst()) {
                MediaService.getInstance().loadAssent(0);
                console.log('is first time playing...')
              } else {
                // 只负责当前歌曲启动还是暂停
                console.log('just click once')
                // 否则只执行暂停或继续
                this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play();
              }
            })
        }

        Image($r('app.media.ic_next'))
          .height($r('app.float.control_icon_height'))
          .width($r('app.float.control_icon_width'))
          .margin({
            right: $r('app.float.control_icon_margin'),
            left: $r('app.float.control_icon_margin')
          })
          .displayPriority(PlayerConstants.DISPLAY_PRIORITY_TWO)
          .onClick(() => MediaService.getInstance().playNextAuto(true))
      }
      .width(120)
      .justifyContent(FlexAlign.End)

    }
    // 绑定模态专场，如说isShowPlay == true 则展示MusicControlComponent
    .bindContentCover($$this.isShowPlay, this.musicPlayBuilder(), ModalTransition.DEFAULT)
    .width(StyleConstants.FULL_WIDTH)
    .height(48)
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .padding({
      left: $r('app.float.player_padding'),
      right: $r('app.float.player_padding')
    })
    // 保持player组件在页面底端
    .position({
      x: 0,
      y: StyleConstants.FULL_HEIGHT
    })
    .translate({
      x: 0,
      y: StyleConstants.TRANSLATE_PLAYER_Y
    })
    // 用于监听滑动事件
    // 如果手指在player区域向上滑动一定距离，唤起MusicControlComponent
    .gesture(
      PanGesture(this.panOption)
        .onActionEnd((event?: GestureEvent) => {
          if (event && event.offsetY < -10) {
            this.isShowPlay = true;
          }
        })
    )
  }

}