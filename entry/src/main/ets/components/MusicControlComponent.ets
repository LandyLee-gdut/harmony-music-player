import { StyleConstants } from "../constant/Constant";
import { common } from "@kit.AbilityKit";
import { display } from "@kit.ArkUI";
import { MusicInfoComponent } from "./MusicInfoComponent";
import { LyricsComponent } from "./LyricsComponent";
import { TopAreaComponent } from "./TopAreaComponent";
import { SongItem } from "../viewmodel/SongItem";
import { MediaTools } from "../utils/MediaTools";
import { effectKit } from "@kit.ArkGraphics2D";
import { Logger } from "../utils/Logger";
import { ColorConversion } from '../utils/ColorConversion'
import ImageCacheUtils from "../utils/ImageCacheUtils";
const TAG = 'MusicControlComponent'
/**
 * 歌曲播放的主界面，由Player组件唤起，展示歌曲相关信息，可以作用滑动切换歌曲专辑封面页面和专辑歌词页
 */
@Component
export struct MusicControlComponent {
  // 判断折叠屏是否展开的变量
  // @StorageLink('isFoldFull') isFoldFull: boolean = false;
  // 歌单列表
  @StorageLink('songList') @Watch('getImageColor') songList: SongItem[] = [];
  // 正在播放的歌曲
  @StorageProp('selectIndex') @Watch('getImageColor') selectIndex: number = 0;
  // 背景颜色（全局取色）
  @StorageLink('imageColor') imageColor: string = 'rgba(0, 0, 2, 1.00)';
  // padding值的大小
  @StorageLink('topArea') topArea: number = 0;
  @StorageLink('bottomArea') bottomArea: number = 0;
  // UIAbility全局上下文对象，在entryAbility中配置
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  // 判断是否展示控制区组件ControlAreaComponent
  @State isShowControl: boolean = true;
  // 判断是否为平板
  @State isTabletFalse: boolean = false;
  // ？
  @State intervalID: number = 0;
  // 记录页面展现次数的变量？
  @StorageLink('pageShowTime') pageShowTime: number = 0;
  // 判断是否展现当前页面（MusicControlComponent）的变量
  @Link isShowPlay: boolean;
  // 背景图片
  @State imageLabel: PixelMap | ResourceStr = this.songList[this.selectIndex].label
  /**
   * Get largest proportion color of an image.
   */
  private imageCacheUtils: ImageCacheUtils = ImageCacheUtils.getInstance(AppStorage.get('context'));
  getImageColor() {
    if (!this.context) {
      return ;
    }
    this.imageCacheUtils.getCachedImagePath(this.songList[this.selectIndex].label as string).then((cacheDir) => {
      MediaTools.getPixelMapFromFile(cacheDir).then((image) => {
        effectKit.createColorPicker(image, (error, colorPicker) => {
          if (error) {
            Logger.error('Failed to create color picker.');
          } else {
            let color = colorPicker.getLargestProportionColor();
            let colorArr = ColorConversion.dealColor(color.red, color.green, color.blue);
            this.imageColor = `rgba(${colorArr[0]}, ${colorArr[1]}, ${colorArr[2]}, 1)`;
          }
          let headFilter = effectKit.createEffect(image);
          if (headFilter !== null) {
            headFilter.blur(30);
            headFilter.getEffectPixelMap().then((value) => {
              this.imageLabel = value;
            })
          }
        })
      })
    })



  }
  private async loadImage(url: string): Promise<PixelMap> {
    try {
      return await MediaTools.getPixelMapFromFile(await this.imageCacheUtils.getCachedImagePath(url));
    } catch (err) {
      Logger.error(TAG, JSON.stringify(url) + 'load image but failed: ' + JSON.stringify(err))
      throw new Error(`\'load image but failed: \' + JSON.stringify(err)`)
    }
  }
  async aboutToAppear() {
    await this.getImageColor()
  }
  build() {
    Stack() {
      Image(this.imageLabel)
        .size({height: '150%'})
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
        .opacity(0.5)
      Row() {
        Stack({ alignContent: Alignment.TopStart }) {
          // 用于左右切换的swiper
          Swiper() {
            // 歌曲信息区
            MusicInfoComponent()
              .margin({
                top: 72,
                bottom: 20
              })
              .padding({
                left: $r('app.float.common_padding'),
                right: $r('app.float.common_padding')
              })
            // 歌曲信息区
            LyricsComponent({ isShowControl: this.isShowControl, isTablet: this.isTabletFalse })
              .margin({
                top: 8
              })
              .padding({
                left: $r('app.float.common_padding'),
                right: $r('app.float.common_padding')
              })
          }
          // Swiper组件的相关属性
          .height(StyleConstants.FULL_HEIGHT)
          .indicator(
            new DotIndicator()
              .top(10)
              .selectedColor($r('app.color.select_swiper'))
              .color($r('app.color.slider_track'))
          )
          .clip(false)
          .loop(false)
          .onChange((index: number) => {
            if (index === 1) {
              this.isShowControl = true;

              this.intervalID = setInterval(() => {
                this.pageShowTime += 1;
                if (this.pageShowTime > 5) {
                  this.isShowControl = false;
                  clearInterval(this.intervalID);
                }
              }, 1000);
            } else {
              this.pageShowTime = 0;
              clearInterval(this.intervalID);
            }
          })
          // 顶层区域：包括关闭musicControlComponent和分享功能
          TopAreaComponent({ isShowPlay: this.isShowPlay })
            .padding({
              left: $r('app.float.common_padding'),
              right: $r('app.float.common_padding')
            })
        }
        .height(StyleConstants.FULL_HEIGHT)
      }
      .padding({
        bottom: this.bottomArea,
        top: this.topArea
      })
    }
    .height(StyleConstants.FULL_HEIGHT)
    .width(StyleConstants.FULL_WIDTH)
    .backgroundColor(this.imageColor)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
  }
}