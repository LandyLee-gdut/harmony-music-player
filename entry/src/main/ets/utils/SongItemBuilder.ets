import { common } from "@kit.AbilityKit";
import { resourceManager } from "@kit.LocalizationKit";
import { SongItem } from "../viewmodel/SongItem";
import { Logger } from "./Logger";
import { BusinessError } from "@kit.BasicServicesKit";
import { getSongUrlAxios, SongDetailI } from "./GetOnlineMusicUtil";
import { AxiosResponse } from "@ohos/axios";
import { JSON } from "@kit.ArkTS";

/**
 * 这个文件不一定有用，因为我们使用网络获取歌曲
 */
export default class SongItemBuilder {
  // 全局上下文对象
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  // 音频文件的路径
  private realUrl: string = '';
  // 音频文件对象
  private songItem: SongItem | null = null;
  // 获取音频源文件
  public async build(songItem: SongItem): Promise<SongItem> {
    this.songItem = songItem;
    if (!this.context) {
      return this.songItem;
    }
    console.log('song url id is: ' + JSON.stringify(this.songItem))
    let realUrl = await getSongRealUrl(this.songItem.id)

    if (realUrl) {
      this.realUrl = realUrl;
    } else {
      Logger.error('get rawfileFd failed')
    }

    Logger.info('MediaAssetBuilder build realUrl:' + JSON.stringify(this.realUrl));
    return this.songItem;
  }

  public getRealUrl(): string {
    Logger.info(`url ${this.realUrl}`)
    return this.realUrl;
  }

  public async release(): Promise<void> {
    if (this.context && this.context !== null && this.songItem !== null) {
      this.context.resourceManager.closeRawFd(this.songItem.src);
    }
    this.songItem = null;
  }
}
export  async function getSongRealUrl(id: number): Promise<string> {
  try {
    const res = await getSongUrlAxios(id);
    console.log('song url res is:' + JSON.stringify(res.data))
    let data = res.data
    let songUrl: string = data.data[0]['url'];
    console.log('song url url is:' + JSON.stringify(songUrl))
    return songUrl
  } catch (err) {
    console.error('error occurred while getting real song url:' + JSON.stringify(err));
    return ''
  }
}