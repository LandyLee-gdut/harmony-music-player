export class SongItem {
  /**
   * Primary Key ID
   */
  id: number = 0;
  /**
   * Name of Music
   */
  title: string = '';
  /**
   * Music Author Name
   */
  singer: string = '';
  /**
   * Music author id
   */
  singer_id?: string = '';
  /**
   * Music Logo Information(VIP\Hi-Res\...)
   */
  mark: ResourceStr = '';
  /**
   * Music Album Photo
   */
  label: ResourceStr = '';
  /**
   * Source Path of Music
   */
  src: string = '';
  /**
   * Index of Current Music List?
   */
  index: number = 0;
  /**
   * Lyric File Path
   */
  lyric: ResourceStr = '';
  /**
   * belong to which song list
   */
  list_id?: number = 0;
}