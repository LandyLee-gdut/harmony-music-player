import { StyleConstants } from "../constant/Constant";

@Component
export struct NavTitle {
  @Prop title: ResourceStr;

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.nav_title_size'))
        .fontColor($r('app.color.font_primary'))
        .lineHeight($r('app.float.nav_title_height'))
        .fontWeight(FontWeight.Bold)
        .margin({
          left: $r('app.float.margin_left_sm'),
          right: $r('app.float.margin_right_sm')
        })
    }
    .justifyContent(FlexAlign.Start)
    .width(StyleConstants.FULL_WIDTH)
    .height($r('app.float.nav_title_height'))
    .backgroundBlurStyle(BlurStyle.Thick)
  }
}