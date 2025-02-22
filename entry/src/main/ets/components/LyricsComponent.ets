/**
 * 渲染歌词的组件，用于MusicControlComponent中
 */
import { StyleConstants } from "../constant/Constant";

@Component
export struct LyricsComponent {
  @Link isShowControl: boolean;
  @Link isTablet: boolean;

  build() {
    Column() {
      Text('暂无歌词数据')
        .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
        .fontSize($r('app.float.font_fourteen'))
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}