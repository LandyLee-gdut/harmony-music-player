import { StyleConstants } from "../constant/Constant"
import { NavTitle } from '../components/NavTitle'
import { UserInfoComponent } from "../components/UserInfoComponent"
import { MoreFunctionComponent } from "../components/MoreFunctionComponent"
import { Player } from "../components/Player"
import { FunctionItem } from "../viewmodel/MineModel"
import { SongItem } from "../viewmodel/SongItem"
import { SingerItem } from "../viewmodel/SingerItem"
import { getSearchResult } from "../viewmodel/MainModel"
import { LoadingFailComponent } from "../components/LoadingFailComponent"
import { AlbumSongListDisplay } from "../components/AlbumSongListDisplay"
import { LoadingComponent } from "../components/LoadingComponent"
import { promptAction } from "@kit.ArkUI"

PersistentStorage.persistProp('recentlyPlayed', [])
PersistentStorage.persistProp('myFavourite',[])

@Component
export struct Mine {
  @Builder
  navTitle(title: ResourceStr) {
    NavTitle({ title: title })
  }
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
  pageInfos: NavPathStack = new NavPathStack()
  @State isLoading: boolean = true;
  @State loadingFail: boolean = false;
  private singers: SingerItem[] = [{
    name: '薛之谦', englishName: 'xuezhiqian'
  },{
    name: '华晨宇', englishName: 'huachenyu',
  },{
    name: '邓紫棋', englishName: 'dengziqi'
  },{
    name: 'Taylor Swift', englishName: 'taylorswift'
  },{
    name: '周深', englishName: 'zhoushen'
  },{
    name: '毛不易', englishName:'maobuyi'
  },{
    name: 'Ed Sheeran', englishName: 'edsheeran'
  },{
    name: '方大同', englishName: 'fangdatong'
  },{
    name: '陶喆', englishName: 'taozhe'
  }]
  @StorageLink('recentlyPlayed') recentlyPlayed: SongItem[] = []
  @StorageLink('myFavourite') myFavourite: SongItem[] = []
  @State randomIndex: number = Math.floor(Math.random() * this.singers.length);
  @State searchSongs: SongItem[] = []

  async aboutToAppear() {
    if (!this.singers || this.singers.length === 0) {
      console.warn("Singers array is empty!");
      return; // 提前返回，避免错误
    }
    const randomSinger: SingerItem = this.singers[this.randomIndex];
    try {
      const res = await getSearchResult(randomSinger.englishName);
      this.searchSongs = res.slice(0,11);
      console.log('searching result:' + JSON.stringify(res));
    } catch (error) {
      this.loadingFail = true;
      console.error("Error during search:", error);
    }
    this.isLoading = false;
  }
  async getData() {
    if (!this.singers || this.singers.length === 0) {
      console.warn("Singers array is empty!");
      return; // 提前返回，避免错误
    }
    this.randomIndex = Math.floor(Math.random() * this.singers.length)
    const randomSinger: SingerItem = this.singers[this.randomIndex];
    try {
      const res = await getSearchResult(randomSinger.englishName);
      this.searchSongs = res.slice(0,11);
      console.log('searching result:' + JSON.stringify(res));
    } catch (error) {
      this.loadingFail = true;
      console.error("Error during search:", error);
    }
    this.isLoading = false;
  }

  onPageHide(): void {
    PersistentStorage.persistProp('recentlyPlayed', this.recentlyPlayed)
    PersistentStorage.persistProp('myFavourite', this.myFavourite)
  }

  build() {
    Column() {
      Navigation(this.pageInfos) {
        Column({ space: 10 }) {
          //
          Blank()
            .height(55)
            .width('100%')
            .backgroundColor($r('app.color.background_secondary'))
          UserInfoComponent()
            .margin({ top: 5 })
          Row() {
            ForEach(this.functions, (item: FunctionItem) => {
              Column() {
                this.FunctionBuilder(item.iconImg, item.text)
              }
              .onClick(() => {
                this.pageInfos.pushPathByName('MyGeDanPage', item.list_id)
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

          // 歌手歌曲
          Column() {
            if (!this.isLoading && this.loadingFail){
              LoadingFailComponent()
                .height('40%')
            } else if (!this.isLoading) {
              Column() {
                Row() {
                  Row() {
                    Text(('为你推荐：' + this.singers[this.randomIndex].name))
                      .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
                      .fontSize(16)
                      .textAlign(TextAlign.Start)
                  }
                  Row() {
                    SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                      .fontSize(16)
                      .onClick(() => {
                        this.isLoading = true
                        this.getData()
                        setTimeout(() => {
                          if (!this.isLoading) {
                            promptAction.showToast({
                              message: '刷新成功！',
                              duration: 1000
                            })
                          }
                        }, 1000)
                      })
                  }
                }
                .padding({left: 15, right: 15})
                .height(40)
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)

                AlbumSongListDisplay({ songList: this.searchSongs })
                  .height('55%')
              }
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(Color.White)
              .borderRadius($r('app.float.common_border_radius'))
            } else {
              LoadingComponent()
                .height('40%')
            }
          }
          .width('100%')

        }
        .padding({ left: 16, right: 16 })
      }
      .title('我的', {
        backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        barStyle: BarStyle.STACK,
      })
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true)
      .hideToolBar(true)
      .backgroundColor($r('app.color.background_secondary'))
      Player()
    }
  }
}