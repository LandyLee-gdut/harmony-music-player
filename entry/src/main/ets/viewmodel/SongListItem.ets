/**
 * 用于表示推荐歌单封面的数据类型
 */

export interface SongListItem {
  /**
   * 歌单id
   */
  id: number;
  /**
   * 歌单封面
   */
  coverImgUrl: ResourceStr;
  /**
   * 歌单名称
   */
  name: string;
  /**
   * 歌单推荐icon
   */
  iconUrl?: ResourceStr
  /**
   * 歌单推荐名称
   */
  iconText?: string
  /**
   * 歌单更新时间
   */
  updateTime?: number | string;
  /**
   * 歌单歌手
   */
  singer?: string;
}