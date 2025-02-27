/**
 * song list component
 */
import { SongItem } from "../viewmodel/SongItem"
import { SongComponent } from "./SongComponent";
import { curves } from "@kit.ArkUI";

@Component
export struct AlbumSongListDisplay {
  @Link songList: SongItem[];

  build() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.songList, (item: SongItem, index: number) => {
            SongComponent({ songItem: item, songList: this.songList })
              .transition(TransitionEffect.asymmetric(
                TransitionEffect.translate({y:200 * (index+1)}).combine(TransitionEffect.OPACITY).animation({ duration: 200 * (index+1) , curve: curves.springMotion(0.6, 0.8)}),
                TransitionEffect.scale({ x:0, y:0 }).combine(TransitionEffect.OPACITY).animation({ duration: 1000 , curve: curves.springMotion(0.6, 0.8)})
              ))
          }, (item: SongItem) => item.title
          )

          Blank().height(50)
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%').height('100%')
  }
}