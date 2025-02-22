import { AlbumSongListDisplay } from "../components/AlbumSongListDisplay"
import { LoadingFailComponent } from "../components/LoadingFailComponent";
import { SongItem } from "../viewmodel/SongItem";
@Builder
export function SearchResultPageBuilder(name: string, param: SongItem[]) {
  SearchResultPage({ result: param })
}

@Component
export struct SearchResultPage {
  @Prop result: SongItem[];
  pageInfos: NavPathStack = new NavPathStack()
  build() {
    NavDestination() {
      if (this.result.length == 0) {
        LoadingFailComponent()
          .height('100%')
          .width('100%')
      } else {
        Column() {
          AlbumSongListDisplay({ songList: this.result })
        }
        .height('100%')
        .width('100%')
      }
    }
    .title('搜索结果')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}