/**
 * Display button for more function
 */
import { it } from "@ohos/hypium"
import { GeDanItem } from "../viewmodel/GeDanItem";

@Preview
@Component
export struct MoreFunctionComponent {
  /**
   * builder for function
   * @param iconImg
   * @param text
   */
  private functions: FunctionItem[] = [
    {
      iconImg: $r('sys.symbol.timer_circle_fill'),
      text: '最近播放',
      path: 'recent',
      list_id: 999
    },
    {
      iconImg: $r('sys.symbol.heart_fill'),
      text: '我的收藏',
      path: 'favourite',
      list_id: 0
    }
  ]

  @Prop pageInfos: NavPathStack;

  @Builder
  FunctionBuilder(iconImg: Resource, text: string) {
    Column() {
      SymbolGlyph(iconImg)
        .fontSize(30)
        .aspectRatio(1)
        .margin({ bottom: 10 })
        .fontColor([$r('app.color.player_icon_color')])
      Text(text)
        .fontSize(14)
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  build() {
    Row() {
      ForEach(this.functions, (item: FunctionItem) => {
        Column() {
          this.FunctionBuilder(item.iconImg, item.text)
        }
        .onClick(() => {
          let geDan: GeDanItem = {
            list_id: item.list_id
          }
          this.pageInfos.pushPathByName('MyGeDanPage', geDan)
        })
        .clickEffect({ level: ClickEffectLevel.HEAVY })
      })

    }
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(80)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.common_border_radius'))
  }
}
interface FunctionItem {
  iconImg: Resource,
  text: string,
  path: string,
  list_id: number
}