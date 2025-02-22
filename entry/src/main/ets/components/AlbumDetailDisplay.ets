/**
 * Component of the upper part of album detail display
 */
import { StyleConstants } from "../constant/Constant"

@Component
export struct AlbumDetailDisplay {
  // photo
  @Prop albumLabel: ResourceStr;
  // title
  @Prop albumTitle: ResourceStr;
  // description / singer
  @Prop albumSubtitle: ResourceStr;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Column() {
        Image(this.albumLabel)
          .width(100)
          .aspectRatio(1)
          .borderRadius(StyleConstants.NORMAL_RADIUS)
          .shadow({ radius: $r('app.float.album_shadow_radius'), color: '#CC000'})
      }
      .margin({
        right: $r('app.float.common_padding')
      })

      Column() {
        // Album Title
        Text(this.albumTitle)
          .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
          .fontSize(StyleConstants.SONG_TITLE_FONT_SIZE)
          .fontColor($r('app.color.font_primary'))
          .textAlign(TextAlign.Start)
          .margin({ bottom: 10 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis})
          .lineHeight(30)
        // Singer
        Text(this.albumSubtitle)
          .fontWeight(FontWeight.Normal)
          .fontSize(StyleConstants.SONG_SINGER_FONT_SIZE)
          .fontColor($r('app.color.background_fourth'))
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .backgroundColor($r('app.color.album_detail_background'))
    .width('100%')
    .height('100%')
    .padding({
      left: $r('app.float.common_padding'),
      right: $r('app.float.common_padding')
    })
  }
}
