@Preview
@Component
export struct LoadingComponent {
  build() {
    Column() {
      LoadingProgress()
        .width(80).height(80)
      Text($r('app.string.loading_prompt'))
        .fontSize(16)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}