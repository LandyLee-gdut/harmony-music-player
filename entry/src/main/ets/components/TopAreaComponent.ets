import { StyleConstants } from "../constant/Constant";
import { curves } from "@kit.ArkUI";

/**
 * 顶层区域：包括关闭musicControlComponent和分享功能
 */
@Component
export struct TopAreaComponent {
  // 用于控制是否展示MusicControlComponent的变量
  @Link isShowPlay: boolean;

  build() {
    Row() {
      // 关闭按钮
      Image($r('app.media.ic_back_down'))
        .width($r('app.float.common_iamge'))
        .height($r('app.float.common_iamge'))
        .onClick(() => {
          this.isShowPlay = false;
        })
      // 分享按钮
      Image($r('app.media.ic_music_share'))
        .width($r('app.float.common_iamge'))
        .height($r('app.float.common_iamge'))
        .objectFit(ImageFit.Contain)
    }
    .height(48)
    .width(StyleConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}