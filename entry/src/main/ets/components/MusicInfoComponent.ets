import { StyleConstants } from "../constant/Constant"
import { SongItem } from "../viewmodel/SongItem";
import { ControlAreaComponent } from './ControlAreaComponent'
import { promptAction } from "@kit.ArkUI";

/**
 * 歌曲播放的主页面
 * 是MusicControlComponent的子组件
 */
@Component
export struct MusicInfoComponent {
  // swiper控制页面的变量
  @State currentTabIndex: number = 0;
  // ?
  @StorageLink('isFoldFull') isFoldFull: boolean = false;
  // 全局歌单对象
  @StorageLink('songList') songList: SongItem[] = [];
  // 全局正在播放的歌曲index
  @StorageProp('selectIndex') selectIndex: number = 0;
  // 我的收藏
  @StorageLink('myFavourite') myFavourite: SongItem[] = []
  public addMyFavouritePlay(songItem: SongItem) {
    const index = this.myFavourite.findIndex(item => item.id === songItem.id); // 根据 id 属性比较
    if (index > -1) {
      this.myFavourite.splice(index, 1);
    }
    this.myFavourite.push(songItem);
  }
  // ?
  @State isShowControl: boolean = false;
  // 专辑封面
  @Builder
  CoverInfo() {
    Row() {
      Image(this.songList[this.selectIndex].label)
        .width(StyleConstants.FULL_WIDTH)
        // 设置图片的比例
        .aspectRatio(1)
        .borderRadius($r('app.float.cover_radius_label'))
        .shadow({
          radius: $r('app.float.shadow_radius'),
          color: $r('app.color.shadow_color'),
          offsetX: 0,
          offsetY: 8
        })
          // 配置专辑封面共享元素效果
        .geometryTransition('songLabel', { follow: true })
        .clip(true)
        .transition(TransitionEffect.OPACITY.animation({ duration: 350, curve: Curve.Friction }))
    }
    .margin($r('app.float.lyric_margin_right_sm'))
  }
  // 歌曲相关信息
  @Builder
  MusicInfo() {
    Column() {
      // 第一行
      // Flex布局
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        // 歌曲名
        Text(this.songList[this.selectIndex].title)
          .fontSize($r('app.float.title_font_play'))
          .fontColor(Color.White)
          .opacity(0.86)
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.ic_public_likes'))
          .width($r('app.float.likes_image'))
          .height($r('app.float.likes_image'))
          .objectFit(ImageFit.Contain)
          .fillColor(Color.White)
          .opacity(0.86)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            this.addMyFavouritePlay(this.songList[this.selectIndex])
            promptAction.showToast({
              message: '收藏成功！',
              duration: 1000
            })
          })
      }
      // 歌手名称
      Text(this.songList[this.selectIndex].singer)
        .textAlign(TextAlign.Start)
        .fontSize($r('app.float.font_fourteen'))
        .fontColor($r('app.color.play_text_color'))
        .width(StyleConstants.FULL_WIDTH)
        .fontWeight(FontWeight.Regular)
    }
    .margin({ top: $r('app.float.music_info_margin_top') })
  }

  build() {
    Column() {
      // 专辑封面
      this.CoverInfo()
      // 歌曲相关信息
      this.MusicInfo()
      Blank()
      // 底部的控制栏
      ControlAreaComponent()
    }
    .height(StyleConstants.FULL_HEIGHT)
    .width(StyleConstants.FULL_HEIGHT)
    .clip(false)
  }


}