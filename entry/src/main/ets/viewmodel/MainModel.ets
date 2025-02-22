import { ApiConstant } from "../constant/ApiConstant";
import { list2str } from "../utils/CommonUtil";
import { getAlbumDetailAxios, getPlaylistDetailAxios,
  getSearchResultAxios,
  getSongUrlAxios } from "../utils/GetOnlineMusicUtil";
import { SongItem } from "./SongItem";
import { songList } from "./SongListData";

/**
 * Model for Main Page
 * Contains all the data that main page needs
 */
export default class MainModel {
}
export interface SongItemI {
  'ar': ArtistI[],
  'name': string,
  'id': number,
  'artists_id': string,
  'song_album_name': string,
  'song_album_id': number,
  'al'?
}
export interface ArtistI {
  'name': string,
  'id': string
}

export async function getAlbumDetail(): Promise<SongItem[]> {
  try {
    const res = await getAlbumDetailAxios(); // Await the Axios response
    let songListAxios: SongItem[] = [];
    console.debug('getting album with songs, axios message:' + JSON.stringify(res.data));

    let data = res.data;
    let picUrl: string = data['album']['picUrl'];
    console.log('song list data' + JSON.stringify(data));
    let playlists: SongItemI[] = data['songs'];

    for (let index = 0; index < playlists.length; index++) {
      const song = playlists[index];
      let artists: ArtistI[] = song.ar;
      let artists_name: string = list2str(artists, 'name');
      let artists_id: string = list2str(artists, 'id');
      let song_name: string = song.name;
      let song_id: number = song.id;

      songListAxios.push({
        title: song_name,
        id: song_id,
        singer: artists_name,
        singer_id: artists_id,
        mark: '',
        label: picUrl,
        lyric: '',
        src: ApiConstant.BASE_URL + ApiConstant.SONG_URL + `?id=${song_id}` + '&level=standard',
        index: index
      });

      console.log('song list is:' + JSON.stringify(songListAxios));
    }
    return songListAxios; // Return the populated array after the async operation is done
  } catch (err) {
    console.error('error occurred while getting album detail:' + JSON.stringify(err));
    return []; // In case of error, return an empty array
  }
}

export async function getPlayListDetail(id: number): Promise<SongItem[]> {
  try {
    const res = await getPlaylistDetailAxios(id); // Await the Axios response
    let songListAxios: SongItem[] = [];
    console.debug('getting playlist with songs, axios message:' + JSON.stringify(res.data));
    let data = res.data;
    // 获取到的歌曲
    let songs: SongItemI[] = data.playlist['tracks'];
    console.log('song list data' + JSON.stringify(songs));

    for (let index = 0; index < songs.length; index++) {
      const song = songs[index];
      let songName: string = song.name;
      let songId: number = song.id;
      let singerName: string = song.al['name']
      let picUrl: string = song.al['picUrl']
      let artistsId: string = song.al['id']
      songListAxios.push({
        title: songName,
        id: songId,
        singer: singerName,
        singer_id: artistsId,
        mark: '',
        label: picUrl,
        lyric: '',
        src: ApiConstant.BASE_URL + ApiConstant.SONG_URL + `?id=${songId}` + '&level=standard',
        index: index
      });

      console.log('song list is:' + JSON.stringify(songListAxios));
    }
    return songListAxios; // Return the populated array after the async operation is done
  } catch (err) {
    console.error('error occurred while getting album detail:' + JSON.stringify(err));
    return []; // In case of error, return an empty array
  }
}

export async function getSearchResult(keywords: string): Promise<SongItem[]> {
  try {
    let songListAxios: SongItem[] = []
    const res = await getSearchResultAxios(keywords); // Await the Axios response
    let data = res.data;
    console.log('searching list result' + JSON.stringify(res));
    console.log('searching list data' + JSON.stringify(data));
    let songs: SongItemI[] = data.result['songs'];
    for (let index = 0; index < songs.length; index++) {
      const song = songs[index];
      let artists: ArtistI[] = song.ar;
      let artists_name: string = list2str(artists, 'name');
      let artists_id: string = list2str(artists, 'id');
      let picUrl: string = song.al['picUrl']
      let song_name: string = song.name;
      let song_id: number = song.id;

      songListAxios.push({
        title: song_name,
        id: song_id,
        singer: artists_name,
        singer_id: artists_id,
        mark: '',
        label: picUrl,
        lyric: '',
        src: ApiConstant.BASE_URL + ApiConstant.SONG_URL + `?id=${song_id}` + '&level=standard',
        index: index
      });
    }
    return songListAxios;
  }catch(err){
    console.error('error occurred while getting album detail:' + JSON.stringify(err));
    return []; // In case of error, return an empty array
  }
}

