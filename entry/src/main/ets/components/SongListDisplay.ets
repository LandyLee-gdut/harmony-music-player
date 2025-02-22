import { StyleConstants } from "../constant/Constant";
import { SongListDisplayItem } from "../viewmodel/SongListDisplayItem";
import { faceDetector } from "@kit.CoreVisionKit";
import { SongListItem } from "../viewmodel/SongListItem";

/**
 * components for song list display
 */
@Component
export struct SongListDisplay {
  @Prop title: string;
  @Prop list: SongListItem[];

  @Prop pageInfos: NavPathStack;

  build() {
    Column() {
      // title
      Row() {
        Text(this.title)
          .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
          .fontSize(20)
      }
      .width('100%')
      Row() {
        Grid() {
          ForEach(
            this.list,
            ( (item: SongListItem) => {
              GridItem() {
                SongList({ songListItem: item })
                  .onClick(() => {
                    let album: SongListItem = {
                      id: item.id,
                      name: item.name,
                      coverImgUrl: item.coverImgUrl,
                      singer: ''
                    }
                    this.pageInfos.pushPathByName('SongListPage', album)
                    console.log('song list button clicked 2')
                  })
              }
            })
          )
        }
        .height(200)
        .edgeEffect(EdgeEffect.Spring)
        .rowsTemplate('1fr')
        .columnsGap(10)
        .scrollBar(BarState.Off)
      }
    }
  }
}


@Component
export struct SongList {
  @Prop songListItem: SongListItem;
  private replaceFlag: boolean = true;
  @State triggerValueReplace: number = 0;

  build() {
    Column() {
        Stack() {
          Image(this.songListItem.coverImgUrl)
            .width(125)
            .height(125)
            .objectFit(ImageFit.Contain)
            .borderRadius(StyleConstants.NORMAL_RADIUS)
          Row() {
            if (this.songListItem.updateTime){
              Text(this.songListItem.iconText)
                .fontSize(16)
                .fontColor(Color.White)
                .maxLines(2)
                .width(40)
                .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
                .alignSelf(ItemAlign.Start)
            }
            // SymbolGlyph(this.replaceFlag ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'))
            //   .fontSize(25)
            //   .fontColor([Color.White])
            //   .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.triggerValueReplace)
            //   .onClick(() => {
            //     this.replaceFlag = !this.replaceFlag;
            //     this.triggerValueReplace = this.triggerValueReplace + 1;
            //   })
            //   .margin({ left: 42 })
          }
          .margin({ bottom: 10, right: 8 })
        }
        .alignContent(Alignment.BottomEnd)
        Column() {
          Text(this.songListItem.name)
            .fontColor($r('app.color.font_secondary'))
            .fontSize(16)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
        }
        .padding({ top: 4, bottom: 2})
    }
    // 弹簧动效
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .height(170)
    .width(125)
  }
}