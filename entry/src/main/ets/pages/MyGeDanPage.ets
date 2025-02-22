import { AlbumDetailDisplay } from "../components/AlbumDetailDisplay"
import { AlbumSongListDisplay } from "../components/AlbumSongListDisplay"
import { getPlayListDetail } from "../viewmodel/MainModel"
import { SongListItem } from "../viewmodel/SongListItem"
import { JSON } from "@kit.ArkTS"
import { SongItem } from "../viewmodel/SongItem"
import { BusinessError } from "@kit.BasicServicesKit"
import { LoadingComponent } from "../components/LoadingComponent"
import { LoadingFailComponent } from "../components/LoadingFailComponent"
import { MediaService } from "../utils/MediaService"
import { GeDanItem } from "../viewmodel/GeDanItem"
import { getGeDan } from "../viewmodel/MineModel"

/**
 * Page of Song List, demonstrate the detail of song list like songs or image
 */


@Builder
export function MyGeDanPageBuilder(name: string, param: number) {
  MyGeDanPage({ list_id: param })
}

@Preview
@Component
export struct MyGeDanPage {

  pageInfos: NavPathStack = new NavPathStack()

  // @Prop albumItem: SongListItem;
  @State songList: SongItem[] = []

  @Prop list_id: number;
  @StorageProp('myFavourite') myFavourite: SongItem[] = []
  @StorageProp('recentlyPlayed') recentlyPlayed: SongItem[] = []
  // 用于判断是否仍在加载数据
  @State isLoading: boolean = false;
  // 加载是否失败
  @State loadFail: boolean = false;

  async aboutToAppear() {
    if (this.list_id == 0) {
      this.songList = this.getRightGeDan(this.myFavourite.reverse())
    }else if (this.list_id == 999) {
      this.songList = this.getRightGeDan(this.recentlyPlayed.reverse())
    }
  }
  private getRightGeDan(list: SongItem[]) {
    let flag = 0;
    for(let i = 0; i < list.length; i++) {
      list[i].index = flag++;
    }
    return list;
  }
  build() {
    NavDestination() {
      if (!this.isLoading) {
        if (this.songList.length == 0) {
          LoadingFailComponent({ info: '暂无数据 '})
            .height('100%')
            .width('100%')
        } else {
          Column() {
            AlbumSongListDisplay({ songList: this.songList })
              .height('100%')
              .width('100%')
          }
          .height('100%')
          .width('100%')
          Column() {
            Blank()
              .height(105)
              .width('100%')
          }
        }
      } else if (!this.isLoading && this.loadFail) {
        LoadingFailComponent()
          .height('100%')
          .width('100%')
      } else {
        LoadingComponent()
          .height('100%')
          .width('100%')
      }
    }
    .title('歌单页面')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}