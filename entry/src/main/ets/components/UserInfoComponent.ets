/**
 * UserInfo Display Row
 */
@Preview
@Component
export struct UserInfoComponent {
  build() {
    Row() {
      // UserImage
      Image($r('app.media.ic_dream'))
        .width(60)
        .aspectRatio(1)
        .clip(true)
        .objectFit(ImageFit.Contain)
        .borderRadius('50%')
        .margin({right: $r('app.float.margin_right')})
      // UserName
      Column() {
        Text('JayLeeeeeeeeeeeeeeeeeeeeeee')
          .fontSize($r('app.float.user_name_font_size'))
          .fontWeight(500)
          .width(200)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .borderRadius($r('app.float.common_border_radius'))
    .width('100%')
    .backgroundColor(Color.White)
    .height(80)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('app.float.common_padding_sm'),
      right: $r('app.float.common_padding_sm')
    })
  }
}