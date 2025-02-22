import { getSearchResult } from "../viewmodel/MainModel";
import { SongItem } from "../viewmodel/SongItem";

@Component
export struct SearchBar {
  @Link text: string;
  @State triggerValueReplace: number = 0;
  @StorageLink('searchSongs') searchSongs: SongItem[] = [];
  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(16)
        .fontColor([Color.Gray])
        .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP), this.triggerValueReplace)
        .effectStrategy(SymbolEffectStrategy.HIERARCHICAL)
        .onClick(() => {
          this.triggerValueReplace = this.triggerValueReplace + 1;
        })
      TextInput({ text: this.text, placeholder: $r('app.string.SearchBar_placeholder')})
        .placeholderColor(Color.Grey)
        .backgroundColor($r('app.color.comp_background_gray'))
        .placeholderFont({ size: 14, weight: 400 })
        .caretColor(Color.Blue)
        .height(40)
        .fontSize(14)
        .width('95%')
        .fontColor(Color.Black)
        .onChange((value: string) => {
          this.text = value
        })
        .onSubmit(async () => {
          await getSearchResult(this.text).then((res) => {
            this.searchSongs = res;
          })
        })
    }.width('100%').backgroundColor($r('app.color.comp_background_gray')).borderRadius(20).padding({left: 10})
  }
}