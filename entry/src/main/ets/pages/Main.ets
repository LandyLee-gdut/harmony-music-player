import { AlbumDisplay } from "../components/AlbumDisplay"
import { MusicListDisplay } from "../components/MusicListDisplay"
import { NavTitle } from "../components/NavTitle"
import { Player } from "../components/Player"
import { SongList, SongListDisplay } from "../components/SongListDisplay"
import { StyleConstants } from "../constant/Constant"
import { getRecommendSongListAxios, getSingerSongsListAxios } from "../utils/GetOnlineMusicUtil"
import { Logger } from "../utils/Logger"
import { MediaService } from "../utils/MediaService"
import MainModel, { getAlbumDetail, getSearchResult } from "../viewmodel/MainModel"
import { songList } from "../viewmodel/SongListData"
import { BusinessError } from "@kit.BasicServicesKit"
import { SongListItem } from "../viewmodel/SongListItem"
import { JSON } from "@kit.ArkTS"
import { SongItem } from "../viewmodel/SongItem"
import { LoadingComponent } from "../components/LoadingComponent"
import { LoadingFailComponent } from "../components/LoadingFailComponent"
import { curves } from "@kit.ArkUI"
import PinYinConverter from '@nutpi/pinyin'
@Component
export struct Main {
  pageInfos: NavPathStack = new NavPathStack()
  private effect: TransitionEffect = TransitionEffect.scale({x:0, y: 0})
  private pinYinConverter: PinYinConverter = new PinYinConverter()

  @Builder
  navTitle(title: ResourceStr) {
    NavTitle({ title: title })
  }
  @State isLoading: boolean = true;
  @State loadingFail: boolean = false;

  // model to manage all variants
  @State mainModel: MainModel = new MainModel();
  // @State albumDisplayItems: AlbumDisplayItem[] = this.mainModel.albumDisplayItems
  @State inputText: string = ''
  @State recommendList: SongItem[] | undefined = [];
  @State loveList: SongItem[] = [];
  @State firstClick: boolean = true;
  // 从网络获取的专辑信息的item
  // 分配给顶部banner
  @State songListItems1: SongListItem[] = []
  // 经典歌单
  @State songListItems2: SongListItem[] = []
  // 精选歌单
  @State songListItems3: SongListItem[] = []
  // 歌单名1
  @State title1: string = '经典歌单';
  // 歌单名2
  @State title2: string = '精选歌单';
  @State triggerValueReplace: number = 0;
  @StorageLink('searchSongs') searchSongs: SongItem[] = [];

  async aboutToAppear() {
    AppStorage.setOrCreate('songList', songList);
    // 需要加载多少歌单
    let limit = 15;

    while (this.isLoading) {
      console.log('getting data once...')
      await this.getData(limit)
    }

    MediaService.getInstance()
  }

  async getData(limit: number) {
    await getRecommendSongListAxios(limit).then((res) => {
      console.debug('getting recommend song lists, axios message:' + JSON.stringify(res.data))
      let data = res.data;
      let playlists: SongListItem[] = data['playlists']

      // 这里的数据分配给顶部banner栏,5个专辑
      for (let index = 0; index < limit/3; index++) {
        const playlist = playlists[index];
        let list_id = playlist.id
        let list_name = playlist.name
        let cover:ResourceStr = playlist.coverImgUrl + '?param=400y400'
        let update_time: string | number | undefined = playlist.updateTime
        this.songListItems1.push({
          'id': list_id,
          'name': list_name,
          'coverImgUrl': cover,
          'updateTime': update_time
        })
      }
      // 经典歌单
      for (let index = limit/3; index < limit*2/3; index++) {
        const playlist = playlists[index];
        let list_id = playlist.id
        let list_name = playlist.name
        let cover:ResourceStr = playlist.coverImgUrl + '?param=400y400'
        let update_time: string | number | undefined = playlist.updateTime
        this.songListItems2.push({
          'id': list_id,
          'name': list_name,
          'coverImgUrl': cover,
          'updateTime': update_time
        })
      }
      // 精选歌单
      for (let index = limit*2/3; index < limit; index++) {
        const playlist = playlists[index];
        let list_id = playlist.id
        let list_name = playlist.name
        let cover:ResourceStr = playlist.coverImgUrl + '?param=400y400'
        let update_time: string | number | undefined = playlist.updateTime
        this.songListItems3.push({
          'id': list_id,
          'name': list_name,
          'coverImgUrl': cover,
          'updateTime': update_time
        })
      }
      console.debug("axios request","res.data.code:%{public}d" + res.status)
    }).catch((err: BusinessError) => {
      console.debug("axios request getRecommendSongList","err.data.code:%d" + err)
      console.debug("axios request",err.message)
      this.isLoading = true;
      this.loadingFail = true
    });

    await getAlbumDetail().then((res: SongItem[]) => {
      this.loveList = res;
      AppStorage.setOrCreate('songList', this.loveList)
    }).catch((err: BusinessError) => {
      console.debug("axios request getAlbumDetail","err.data.code:%d" + err)
      console.debug("axios request",err.message)
      this.isLoading = true;
      this.loadingFail = true
    });
    this.isLoading = false;
  }

  build() {
    Column() {
      Navigation(this.pageInfos){
        if (!this.isLoading) {
          Stack({ alignContent: Alignment.TopStart }) {
            Column() {
              Scroll(){
                Column(){
                  Blank()
                    .height(60)
                    .width('100%')
                    .backgroundColor(Color.White)

                  // search bar
                  Row() {
                    SymbolGlyph($r('sys.symbol.magnifyingglass'))
                      .fontSize(16)
                      .fontColor([Color.Gray])
                      .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP), this.triggerValueReplace)
                      .effectStrategy(SymbolEffectStrategy.HIERARCHICAL)
                      .onClick(() => {
                        this.triggerValueReplace = this.triggerValueReplace + 1;
                      })

                    TextInput({ text: this.inputText, placeholder: $r('app.string.SearchBar_placeholder')})
                      .placeholderColor(Color.Grey)
                      .backgroundColor($r('app.color.comp_background_gray'))
                      .placeholderFont({ size: 14, weight: 400 })
                      .caretColor(Color.Blue)
                      .height(40)
                      .fontSize(14)
                      .width('95%')
                      .fontColor(Color.Black)
                      .onChange((value: string) => {
                        this.inputText = value
                      })
                      .onSubmit(async () => {
                        // 转换中文为拼音
                        let text: string = this.pinYinConverter.convert(this.inputText).toLowerCase()
                        // 进行搜索
                        await getSearchResult(text).then((res) => {
                          this.searchSongs = res;
                          console.log('searching result:' + JSON.stringify(res))
                          this.inputText = ''
                        }).catch((err: Error) => {
                          Logger.error('error occur while searching songs:' + JSON.stringify(err.message))
                        })
                        // 获取结果后，跳转页面
                        this.pageInfos.pushPathByName('SearchResultPage', this.searchSongs)
                      })
                  }.width('100%').backgroundColor($r('app.color.comp_background_gray')).borderRadius(20).padding({left: 10})

                  // banner
                  Grid() {
                    ForEach(this.songListItems1, (item: SongListItem, index: number) => {
                      GridItem() {
                        AlbumDisplay({ songList: item })
                      }
                      .transition(TransitionEffect.translate({x:500 * (index+1)}).animation({ duration: 500 * (index+1) , curve: curves.springMotion()}))
                      .onClick(() => {
                        let album: SongListItem = {
                          id: item.id,
                          name: item.name,
                          coverImgUrl: item.coverImgUrl,
                          singer: ''
                        }
                        this.pageInfos.pushPathByName('SongListPage', album)
                        console.log('song list button clicked')
                      })
                    })
                  }
                  .edgeEffect(EdgeEffect.Spring)
                  .rowsTemplate('1fr')
                  .columnsGap(10)
                  .scrollBar(BarState.Off)
                  .height(250)
                  .padding({ top: 2 })

                  MusicListDisplay({ title: '猜你喜欢', list: this.loveList })

                  BlankSpace()
                  // 歌单推荐1
                  Column() {
                    // title
                    Row() {
                      Text(this.title1)
                        .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
                        .fontSize(20)
                    }
                    .width('100%')

                    Row() {
                      Grid() {
                        ForEach(
                          this.songListItems2,
                          ((item: SongListItem, index:number) => {
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
                                .transition(TransitionEffect.translate({x:300 * (index+1)}).animation({ duration: 500 * (index+1) , curve: curves.springMotion()}))
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
                  // 歌单推荐2
                  Column() {
                    // title
                    Row() {
                      Text(this.title2)
                        .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
                        .fontSize(20)
                    }
                    .width('100%')
                    Row() {
                      Grid() {
                        ForEach(
                          this.songListItems3,
                          ((item: SongListItem) => {
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
                  Blank()
                    .height(60)
                    .width('100%')
                }
                .width('100%')
              }
              .width('100%')
              .edgeEffect(EdgeEffect.Spring)
              .scrollBar(BarState.Off)
            }
            .padding({ left: 16, right: 16 })
          }
        } else if (!this.isLoading && this.loadingFail) {
          LoadingFailComponent()
          Button('再次刷新')
            .onClick(() => {
              this.loadingFail = false;
              this.getData(15)
            })
        }
        else {
          LoadingComponent()
        }
      }
      .title('推荐', {
        backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        barStyle: BarStyle.STACK,
      })
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true)
      Player()
    }
  }
}
@Component
struct BlankSpace {
  build() {
    Blank().height(15).width('100%')
  }
}