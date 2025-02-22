import { getGeDanAxios } from "../utils/GetOnlineMusicUtil";
import { SongItemI } from "./MainModel";
import { SongItem } from "./SongItem";

export class MineModel {
}

export async function getGeDan(list_id: number): Promise<SongItem[]> {
  try {
    const res = await getGeDanAxios(list_id); // Await the Axios response
    console.debug('getting ge dan with songs, axios message:' + JSON.stringify(res.data));
    let data = res.data;
    console.log('ge dan data' + JSON.stringify(data));
    let songList: SongItem[] = data.data;
    console.log('ge dan data' + JSON.stringify(songList));
    return songList; // Return the populated array after the async operation is done
  } catch (err) {
    console.error('error occurred while getting ge dan detail:' + JSON.stringify(err));
    return []; // In case of error, return an empty array
  }
}

export interface FunctionItem {
  iconImg: Resource,
  text: string,
  path: string,
  list_id: number
}