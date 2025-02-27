import { StyleConstants } from "../constant/Constant"
import { SongListItem } from "../viewmodel/SongListItem"
import ImageCacheUtils from '../utils/ImageCacheUtils'
import { MediaTools } from '../utils/MediaTools'
@Component
export struct AlbumDisplay {
  @Prop songList: SongListItem;
  private imageCacheUtils: ImageCacheUtils = ImageCacheUtils.getInstance(AppStorage.get('context'));
  @State image: PixelMap | undefined = undefined
  aboutToAppear() {
    this.loadImage(this.songList.coverImgUrl as string);
  }

  private async loadImage(url: string) {
    this.image = await MediaTools.getPixelMapFromFile(await this.imageCacheUtils.getCachedImagePath(url));
  }
  build() {
    Column() {
      Stack() {
        Column() {
          Stack({ alignContent: Alignment.BottomEnd }){
            Image(this.image)
              .width('100%')
              .objectFit(ImageFit.Cover)
              .height(215)
              .borderRadius(16)
            Column() {
              Text(this.songList.name)
                .width('100%')
                .fontSize(16)
                .fontWeight(700)
                .fontColor($r('app.color.background_secondary'))
                .textAlign(TextAlign.Start)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textAlign(TextAlign.Start)
                .padding({ left: 12, top: 12, right: 12 })
                .maxLines(2)
            }
            .borderRadius({
              bottomLeft: 16,
              bottomRight: 16
            })
            .height(60)
            .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
          }
        }
        Row() {
          if (this.songList.iconUrl) {
            Image(this.songList.iconUrl)
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .margin({ right: 5 })
          }
          if (this.songList.iconText) {
            Text(this.songList.iconText)
              .fontSize(20)
              .fontWeight(700)
              .fontColor(Color.White)
              .lineHeight(24)
          }
        }.width(StyleConstants.FULL_WIDTH).height(30).alignItems(VerticalAlign.Center)
        .padding({ top: 8, left: 10, right: 10 })
      }
      .alignContent(Alignment.TopStart)
    }
    .width(160)
    .height(215)
    .borderRadius(16)
    // 点击后的弹簧动效
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
  }
}