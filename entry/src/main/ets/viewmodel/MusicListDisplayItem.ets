export interface MusicListDisplayItem {
  imageUrl: ResourceStr;
  songName: string;
  singer: string;
}

export function getFormattedName(nameList: string): string {
  let list = nameList.split(',')

  let str: string = list[0]
  if (list.length > 1) {
    for (let index = 1; index < list.length; index++) {
      const element = list[index];
      str += ('/' + element)
    }
  }
  return str;
}