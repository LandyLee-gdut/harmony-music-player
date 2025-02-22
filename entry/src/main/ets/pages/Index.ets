import { Mine } from './Mine';
import { Main } from  './Main'
import { Player } from '../components/Player';
import app, { AppResponse } from '@system.app'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  onPageShow(): void {
    app.setImageCacheCount(50)
  }

  @Builder
  tabBuilder(index: number, text: string, defaultIcon: ResourceStr, selectedIcon: ResourceStr) {
    Column() {
      Image(index == this.selectedIndex? selectedIcon:defaultIcon)
        .width(24)
        .height(24)
        .margin({ bottom: 5 })
      Text(text)
        .fontSize(12)
        .lineHeight(12)
        .fontWeight(700)
        .fontColor(index == this.selectedIndex? $r('app.color.brand_default_color_100'): $r('app.color.font_primary'))
    }
  }
  private pageInfos: NavPathStack = new NavPathStack()
  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          Main()
        }.tabBar(this.tabBuilder(0, '首页', $r('app.media.ic_home'), $r('app.media.ic_home_selected')))
        TabContent() {
          Mine()
        }.tabBar(this.tabBuilder(1, '我的', $r('app.media.person_crop_circle_fill_1'), $r('app.media.person_crop_circle_fill_1_selected')))
      }
      .scrollable(false)
      .height('100%')
      .barHeight($r('app.float.bar_height'))
      // .barOverlap(true)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        // currentIndex控制TabContent显示页签
        this.currentIndex = index
        this.selectedIndex = index
      })
    }
    .width('100%').height('100%')
  }
}