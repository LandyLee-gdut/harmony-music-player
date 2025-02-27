import { AlbumDetailDisplay } from "../components/AlbumDetailDisplay"
import { AlbumSongListDisplay } from "../components/AlbumSongListDisplay"
import { getPlayListDetail } from "../viewmodel/MainModel"
import { SongListItem } from "../viewmodel/SongListItem"
import { JSON } from "@kit.ArkTS"
import { SongItem } from "../viewmodel/SongItem"
import { BusinessError } from "@kit.BasicServicesKit"
import { LoadingComponent } from "../components/LoadingComponent"
import { LoadingFailComponent } from "../components/LoadingFailComponent"

/**
 * Page of Song List, demonstrate the detail of song list like songs or image
 */


@Builder
export function SongListPageBuilder(name: string, param: SongListItem) {
  SongListPage({ albumItem: param })
}

@Preview
@Component
export struct SongListPage {

  pageInfos: NavPathStack = new NavPathStack()

  @Prop albumItem: SongListItem;
  @State songList: SongItem[] = []

  // 用于判断是否仍在加载数据
  @State isLoading: boolean = false;
  // 加载是否失败
  @State loadFail: boolean = false;

  async aboutToAppear() {
    console.log('album item is:' + JSON.stringify(this.albumItem))
    await getPlayListDetail(this.albumItem.id).then((res: SongItem[]) => {
      this.songList = res;
    }).catch((err: BusinessError) => {
      console.debug("axios request getAlbumDetail","err.data.code:%d" + err)
      console.debug("axios request",err.message)
      this.isLoading = true;
      this.loadFail = true;
    });
  }

  build() {
    NavDestination() {
      if (!this.isLoading && this.loadFail) {
        AlbumDetailDisplay({ albumLabel: this.albumItem.coverImgUrl, albumTitle: this.albumItem.name, albumSubtitle: this.albumItem.singer })
          .height('30%')
          .width('100%')
        LoadingFailComponent()
          .height('70%')
          .width('100%')
      } else if (!this.isLoading) {
        Column() {
          AlbumDetailDisplay({ albumLabel: this.albumItem.coverImgUrl, albumTitle: this.albumItem.name, albumSubtitle: this.albumItem.singer })
            .height('30%')
            .width('100%')
          AlbumSongListDisplay({ songList: this.songList })
            .height('70%')
            .width('100%')
        }
        .height('100%')
        .width('100%')
        Column() {
          Blank()
            .height(105)
            .width('100%')
        }
      } else {
        AlbumDetailDisplay({ albumLabel: this.albumItem.coverImgUrl, albumTitle: this.albumItem.name, albumSubtitle: this.albumItem.singer })
          .height('30%')
          .width('100%')
        LoadingComponent()
          .height('70%')
          .width('100%')
      }
    }
    .title('歌单页面')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}