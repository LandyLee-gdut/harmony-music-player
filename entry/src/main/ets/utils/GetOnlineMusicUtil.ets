// 引入包名
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { httpRequestGet } from './HttpUtil';
import { RandMusicItem } from '../viewmodel/RandMusicItem'
import ResponseResult from '../viewmodel/ResponseResult';
import { CommonConstant as Const, ContentType } from '../constant/CommonConstant';
import { promptAction } from '@kit.ArkUI';
import { SongListItem } from '../viewmodel/SongListItem';
import { ApiConstant } from '../constant/ApiConstant';
import { axiosClient, HttpPromise } from './AxiosUtil';
import { SongItem } from '../viewmodel/SongItem';

export function getRandMusic(sort?: string):Promise<RandMusicItem> {
  return new Promise((resolve: Function, reject: Function) => {
    let url: string = `http://api.uomg.com/api/rand.music?format=json`
    httpRequestGet(url).then((data: ResponseResult) => {
      if (data.code === Const.SERVER_CODE_SUCCESS) {
        console.log("Rand Music if:" + JSON.stringify(data))
        resolve(data.data);
      } else {
        console.log("Rand Music else:" + JSON.stringify(data))
        promptAction.showToast({
          message: $r('app.string.http_error_message'),
          duration: 1000
        })
      }
    }).catch((err: Error) => {
      console.log("Rand Music:" + JSON.stringify(err))
      promptAction.showToast({
        message: $r('app.string.http_error_message'),
        duration: 1000
      })
    });
  });

}

/**
 * 获取10个精品推荐专辑，返回专辑对象相关信息
 */


// 获取热门影视接口,仅作为post的使用示例，未使用
export const getRecommendSongListAxios = (limit: number = 15): HttpPromise<SongListItem[]> => axiosClient.get({headers: undefined, url: ApiConstant.HIGH_QUALITY_LIST + `?limit=${limit}`});

export const getNewSongListAxios = (limit: number = 15): HttpPromise<SongListItem[]> => axiosClient.get({headers: undefined, url: ApiConstant.NEW_SONG_LIST + `?limit=${limit}&order=new`});

export const getSingerSongsListAxios = (id: number = 5781, limit: number = 15): HttpPromise<SongItem[]> => axiosClient.get({headers: undefined, url: ApiConstant.SINGER_SONGS + `?limit=${limit}&id=${id}`});

export const getAlbumDetailAxios = (id: number = 242274622): HttpPromise<SongItem[]> => axiosClient.get({headers: undefined, url: ApiConstant.ALBUM_DETAIL + `?id=${id}`});

export const getSongUrlAxios = (id: number, level: string = 'standard'): HttpPromise<Result> => axiosClient.get({headers: undefined, url: ApiConstant.SONG_URL + `?id=${id}&level=standard`});

export const getPlaylistDetailAxios = (id: number): HttpPromise<PlaylistI> => axiosClient.get({headers: undefined, url: ApiConstant.PLAYLIST_DETAIL + `?id=${id}&level=standard`})

export const getSearchResultAxios = (keywords: string, limit: number = 20): HttpPromise<Result> => axiosClient.get({headers: undefined, url: ApiConstant.CLOUD_SEARCH + '?keywords=' + keywords + `&limit=${limit}` });

export interface SongDetailI{
  id: number,
  url: string,
  size: number
}
export interface PlaylistI {
  code,
  playlist
}
export interface Result {
  data,
  msg,
  code,
  result
}
export interface ResultI {
  result
}