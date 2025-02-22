import { StyleConstants } from "../constant/Constant";
import { getFormattedName, MusicListDisplayItem } from '../viewmodel/MusicListDisplayItem'
import { getRandMusic } from '../utils/GetOnlineMusicUtil'
import { RandMusicItem } from "../viewmodel/RandMusicItem";
import ResponseResult from "../viewmodel/ResponseResult";
import { SongItem } from "../viewmodel/SongItem";
import { MediaService } from "../utils/MediaService";
import { curves } from "@kit.ArkUI";

@Component
export struct MusicListDisplay{
  @Prop title: string;
  @Link list: SongItem[];
  private effect: TransitionEffect = TransitionEffect.scale({x:0, y:0})
  build() {
    Column() {
      // title
      Row() {
        Text(this.title)
          .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
          .fontSize(20)
      }
      .width('100%')
      .margin({
        bottom: 5
      })

      // music list
      Column() {
        Grid() {
          ForEach(
            this.list,
            ( (item: SongItem, index: number) => {
              GridItem() {
                MusicItem( { songItem: item, songList: this.list })
                  .transition(this.effect.animation({ duration: 500 * (index+1) , curve: curves.springMotion()}))
              }
            })
          )
        }
        .height(200)
        .edgeEffect(EdgeEffect.Spring)
        .rowsTemplate('1fr 1fr 1fr')
        .columnsGap(10)
        .scrollBar(BarState.Off)
      }
      .height('100%')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .height(220)
    .justifyContent(FlexAlign.Start)
  }
}
/**
 * 歌曲基本信息展示的组件，可以多次复用
 */
@Component
export struct MusicItem{
  @Prop songList: SongItem[];

  @Prop songItem: SongItem;
  @State triggerValueReplace: number = 0;
  @State musicUrl: string | undefined = undefined
  updateFlag() {
    // 判断图标是否变化
    this.replaceFlag = this.isPlay? (this.selectIndex == this.songItem.index ? true : false) : false
  }
  // 监听isPlay变化情况
  @StorageLink('isPlay') @Watch('updateFlag') isPlay: boolean = false;
  @StorageLink('selectIndex') @Watch('updateFlag') selectIndex: number = 0;
  // 最近播放
  @StorageLink('recentlyPlayed') recentlyPlayed: SongItem[] = [];

  @State replaceFlag: boolean = false;
  // 添加到最近播放的逻辑
  public addRecentlyPlayed(songItem: SongItem) {
    const index = this.recentlyPlayed.findIndex(item => item.id === songItem.id); // 根据 id 属性比较
    if (index > -1) {
      this.recentlyPlayed.splice(index, 1);
    }
    this.recentlyPlayed.push(songItem);
  }
  aboutToAppear(): void {
    this.updateFlag()
  }

  build() {
    Row() {
      // 歌曲专辑封面
      Image(this.songItem.label)
        .height(50)
        .height(50)
        .objectFit(ImageFit.Auto)
        .aspectRatio(1)
        .borderRadius(8)
      Column({ space: 3 }) {
        // 歌名
        Text(this.songItem.title)
          .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
          .fontSize(15)
          .fontColor($r('app.color.font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        // 歌手
        Text(getFormattedName(this.songItem.singer))
          .fontSize(13)
          .fontColor($r('app.color.font_tertiary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width(150)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })
      Blank()
      Column() {
        // 播放按钮
        SymbolGlyph(this.replaceFlag && ((AppStorage.get('songList') as SongItem[])[this.selectIndex].id == this.songItem.id) ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
          .fontSize(20)
          .fontColor([$r('sys.color.ohos_id_color_text_secondary')])
          .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.triggerValueReplace)
      }
      .margin({ right: 10 })
    }
    .width(320)
    .height(50)
    .onClick(() => {
      this.triggerValueReplace = this.triggerValueReplace + 1;
      // 如果是第一次播放，播放第一首歌
      console.log('just click once')
      if (this.songList != AppStorage.get('songList')) {
        // 更新全局歌单
        AppStorage.setOrCreate('songList', this.songList)
        // 更新mediaService中的歌单
        MediaService.getInstance().renewSongList(this.songList)
      }

      // 否则只执行暂停或继续
      if (!this.isPlay) {
        MediaService.getInstance().loadAssent(this.songItem.index);
        this.replaceFlag = !this.isPlay
        this.addRecentlyPlayed(this.songItem)
        return;
      }
      else if (this.isPlay && this.selectIndex != this.songItem.index) {
        MediaService.getInstance().pause()
        MediaService.getInstance().loadAssent(this.songItem.index);
        this.addRecentlyPlayed(this.songItem)
      }
      else {
        // 正在播放，会暂停，正在暂停，会播放
        this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play();
      }

    })
    // 弹簧动效
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
  }
}