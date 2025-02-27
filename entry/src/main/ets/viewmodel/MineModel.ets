import { SongItemI } from "./MainModel";
import { SongItem } from "./SongItem";

export class MineModel {
}


export interface FunctionItem {
  /**
   * icon of the function button
   */
  iconImg: Resource,
  /**
   * text of the function button
   */
  text: string,
  /**
   * route path for navigation
   */
  path: string,
  /**
   * id of function button
   */
  list_id: number
}