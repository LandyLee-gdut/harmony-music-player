/**
 * class for Api URL constant
 */
export class ApiConstant {
  /**
   * URL for high quality song list
   * params:
   *  limit: number -> number limitation of response song lists
   *  before: number -> update time of final song list to get new recommendation
   */
  static readonly HIGH_QUALITY_LIST: string = '/top/playlist/highquality'
  /**
   * URL for song list detail
   * params:
   *  id: number -> specific song list id
   */
  static readonly SONG_LIST_DETAIL: string = '/playlist/detail';
  /**
   * URL for new song song list
   * params:
   *  limit: number -> number limitation of response song lists
   *  order: string(new, hot) -> get hot songs or new songs
   */
  static readonly NEW_SONG_LIST = '/top/playlist'
  /**
   * URL to get specific singer's song
   * params:
   *  id: number -> singer id
   *  limit: number -> max songs return
   */
  static readonly SINGER_SONGS = '/artist/songs'
  /**
   * URL to get album information
   * params:
   *  id: number -> album id
   */
  static readonly ALBUM_DETAIL = '/album'
  /**
   * URL to get song url
   * params:
   *  id: number -> song id
   *  level: string(standard) -> song quality
   */
  static readonly SONG_URL = '/song/url/v1'
  /**
   * Base URL
   */
  static readonly BASE_URL = "YOUR BASE URL"
  /**
   * URL to get playlist detail info
   * params:
   *  id: playlist id
   */
  static readonly PLAYLIST_DETAIL = '/playlist/detail'
  /**
   * URL to search songs
   * params:
   *  keywords: string
   *  limit: number
   */
  static readonly SEARCH = '/search'

  static readonly CLOUD_SEARCH = '/cloudsearch'
  /**
   * params:
   *  list_id: number
   */
  static readonly GE_DAN = '/song_list/getSong'
}