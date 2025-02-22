import { ArtistI } from "../viewmodel/MainModel";

export function list2str(list: ArtistI[], value:string): string {
  if (value == 'name') {
    let str: string = list[0].name
    if (list.length > 1) {
      for (let index = 1; index < list.length; index++) {
        const element: string = list[index].name;
        str += ('/' + element)
      }
    }
    return str;
  } else {
    let str: string = list[0].id
    if (list.length > 1) {
      for (let index = 1; index < list.length; index++) {
        const element: string = list[index].id;
        str += ('/' + element)
      }
    }
    return str;
  }

}