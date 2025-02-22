
@Component
export struct LoadingFailComponent {
  @Prop info?: ResourceStr;
  build() {
    Column() {
      SymbolGlyph($r('sys.symbol.exclamationmark_circle'))
        .fontSize(60)
        .margin({ bottom: 10 })
      Text(this.info? this.info : $r('app.string.loading_fail'))
        .fontSize(16)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}