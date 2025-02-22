import { StyleConstants } from '../constant/Constant';
import { MediaService } from '../utils/MediaService'
/**
 * 歌曲播放洁面下方的工具控制栏
 */
@Component
export struct ControlAreaComponent {
  // 全局变量：歌曲是否正在播放
  @StorageLink('isPlay') isPlay: boolean = false;

  // slider组件的相关属性
  @StorageLink('progress') value: number = 0;
  @StorageLink('progressMax') max: number = 0;
  // 页面展示的时间？
  @StorageLink('pageShowTime') pageShowTime: number = 0;

  // 全局变量：当前播放时间
  @StorageLink('currentTime') currentTime: string = '00:00';
  // 全局变量：歌曲总时长
  @StorageLink('totalTime') totalTime: string = '00:00';
  // 全局取色
  @StorageLink('imageColor') imageColor: string = '';

  build() {
    Column() {
      // 音频进度的控制条
      Column() {
        Slider({ min: 0, max: this.max, step: 1, value: this.value })
          .blockColor($r('app.color.slider_block'))
          .selectedColor($r('app.color.slider_select'))
          .trackColor($r('app.color.slider_track'))
          .blockSize({
            width: $r('app.float.slider_block'),
            height: $r('app.float.slider_block')
          })
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.End || mode === SliderChangeMode.Begin) {
              MediaService.getInstance().seek(value);
            }
            this.pageShowTime = 0;
          })
          .height(16)
          .margin({
            left: -4, right: -4,
          })
          .hitTestBehavior(HitTestMode.Block)
        Row() {
          Text(this.currentTime)
            .fontColor($r('app.color.play_text_color'))
            .fontSize(10)
            .lineHeight('14vp')
          Text(this.totalTime)
            .fontColor($r('app.color.play_text_color'))
            .fontSize(10)
            .lineHeight('14vp')
        }
        .width(StyleConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .margin({
        top:24, bottom: 12
      })
      // 前一首歌、暂停播放、下一首歌
      Row() {
        // 上一首歌
        Image($r('app.media.ic_public_forward'))
          .controlImageBuilder()
          .width(32)
          .onClick(() => {
            MediaService.getInstance().playPrevious();
            this.pageShowTime = 0;
          })
        Image(this.isPlay? $r('app.media.ic_public_play') : $r('app.media.ic_public_pause'))
          .controlImageBuilder()
          .width(72)
          .onClick(() => {
            if (this.isPlay) {
              MediaService.getInstance().pause()
            } else {
              // 判断是否是第一首播放的歌曲
              if (MediaService.getInstance().getFirst()) {
                // 如果是，按index 0播放歌曲
                MediaService.getInstance().loadAssent(0);
              } else {
                // 直接播放
                MediaService.getInstance().play();
              }
            }
            // 设置播放时间为0
            this.pageShowTime = 0;
          })
        Image($r('app.media.ic_public_next'))
          .controlImageBuilder()
          .width(32)
          .onClick(() => {
            // 播放下一首
            MediaService.getInstance().playNextAuto(true);
            // 设置播放时间为0
            this.pageShowTime = 0;
          })
      }
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 36,
        right: 36
      })

    }
  }
}

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .opacity(0.86)
  .objectFit(ImageFit.Contain)
}