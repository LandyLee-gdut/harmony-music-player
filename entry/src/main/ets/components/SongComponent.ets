import { StyleConstants } from "../constant/Constant";
import { MediaService } from "../utils/MediaService";
import { getFormattedName } from "../viewmodel/MusicListDisplayItem";
import { SongItem } from "../viewmodel/SongItem";

/**
 * Single Song Component
 */
@Component
export struct SongComponent {
  @State firstClick: boolean = true;
  @Prop songItem: SongItem;
  @Prop songList: SongItem[];
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
      Text(JSON.stringify(this.songItem.index + 1))
        .margin({right: 10})
        .fontWeight(FontWeight.Normal)
        .fontSize(14)
        .fontColor($r('app.color.font_secondary'))
        .width(20)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Column({ space: 3 }) {
        // 歌名
        Text(this.songItem.title)
          .fontWeight(StyleConstants.BOLD_FONT_WEIGHT)
          .fontSize(15)
          .fontColor($r('app.color.font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
        // 歌手
        Text(getFormattedName(this.songItem.singer))
          .fontSize(13)
          .fontColor($r('app.color.font_tertiary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
      }
      .width(200)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })

      Blank()

      Column() {
        // 播放按钮
        SymbolGlyph(this.replaceFlag && this.songItem.id == (AppStorage.get('songList') as SongItem[])[this.selectIndex].id ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
          .fontSize(20)
          .fontColor([$r('sys.color.ohos_id_color_text_secondary')])
          .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.triggerValueReplace)
      }
      .margin({ right: 10 })
    }
    .width('100%')
    .height(50)
    .padding({
      top: 10,
      left: 15,
      right: 15
    })
    .margin({ bottom: 10 })
    // 播放歌曲的逻辑
    .onClick(() => {
      this.triggerValueReplace = this.triggerValueReplace + 1;
      // 如果是第一次播放，播放第一首歌
      console.log('touch and renew the song list')
      // AppStorage.setOrCreate('songList', this.songList)
      console.log('song list:' + JSON.stringify(AppStorage.get('songList')))
      // 判断是否需要更新全局歌单信息
      if (this.songList != AppStorage.get('songList')) {
        // 更新全局歌单
        AppStorage.setOrCreate('songList', this.songList)
        // 更新mediaService中的歌单
        MediaService.getInstance().renewSongList(this.songList)
      }
      // 歌单歌曲不需要这个逻辑
      // if (MediaService.getInstance().getFirst()) {
      //   MediaService.getInstance().loadAssent(0);
      //   return;
      // }
      // 否则只执行暂停或继续
      if (!this.isPlay) {
        MediaService.getInstance().loadAssent(this.songItem.index);
        this.selectIndex = this.songItem.index
        this.replaceFlag = !this.isPlay
        this.addRecentlyPlayed(this.songItem)
        return;
      }
      else if (this.isPlay && this.selectIndex != this.songItem.index) {
        MediaService.getInstance().pause()
        MediaService.getInstance().loadAssent(this.songItem.index);
        this.selectIndex = this.songItem.index
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