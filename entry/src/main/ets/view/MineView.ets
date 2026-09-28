import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import { gearList, safetyTips, sunriseInfo, IGearItem, ISafetyTip } from '../viewmodel/PlanModel';

/**
 * Tab4「夜爬准备」页面组件。
 *
 * - 顶部：东峰观日信息（夜爬的最终目标）+ 装备准备进度；
 * - 中部：装备清单，点一下勾选，未勾选时圆点空心、勾选后填充暖黄；「必带」项单独标记；
 * - 底部：安全须知（每条一句标题 + 说明）。
 */
@Component
export struct MineView {
  /**
   * 装备勾选状态，下标与 gearList 一一对应。
   */
  @State checked: Array<boolean> = gearList.map((item: IGearItem) => !item.required);
  /**
   * 安全须知展开项下标（-1 = 全部收起）。
   */
  @State expandedTip: number = -1;

  /**
   * 已备齐数量。
   */
  private readyCount(): number {
    let count = 0;
    for (let i = 0; i < this.checked.length; i++) {
      if (this.checked[i]) {
        count++;
      }
    }
    return count;
  }

  /**
   * 切换某个装备的勾选状态。
   *
   * 注意：ArkUI 只有整个数组被重新赋值时才会触发刷新，所以这里用 slice 生成新数组。
   */
  private toggleGear(index: number): void {
    const next: Array<boolean> = this.checked.slice();
    next[index] = !next[index];
    this.checked = next;
  }

  private toggleTip(index: number): void {
    this.getUIContext().animateTo(
      { duration: Const.FUNC_AREA_ANIMATION, curve: Curve.EaseInOut }, () => {
        this.expandedTip = this.expandedTip === index ? -1 : index;
      }
    );
  }

  build() {
    Column() {
      // 页面标题。
      Column({ space: 4 }) {
        Text(Const.GEAR_TITLE)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Const.NIGHT_TEXT)
        Text(`装备已备齐 ${this.readyCount()} / ${gearList.length} 项 · 目标 ${sunriseInfo.spot}`)
          .fontSize(12)
          .fontColor(Const.NIGHT_TEXT_SUB)
      }
      .width(Const.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN, top: 14, bottom: 10 })

      Scroll() {
        Column({ space: Const.LIST_ITEM_GAP }) {
          this.buildGearCard()
          this.buildSafetyCard()
          Text('本 App 海拔、里程、时刻与观日数据均为演示用示意值，出行前请以华山景区官方公告为准。')
            .fontSize(11)
            .fontColor(Const.NIGHT_TEXT_SUB)
            .lineHeight(17)
            .margin({ top: 2, bottom: 18 })
        }
        .width(Const.FULL_PERCENT)
        .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN })
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      .width(Const.FULL_PERCENT)
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .backgroundColor(Const.NIGHT_BG)
  }

  /**
   * 装备清单卡片：点一下勾选，进度条显示备齐比例。
   */
  @Builder
  buildGearCard() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('装备清单')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Const.NIGHT_TEXT)
        Blank()
        Text(`${this.readyCount()}/${gearList.length}`)
          .fontSize(12)
          .fontColor(Const.NIGHT_ACCENT)
      }
      .width(Const.FULL_PERCENT)

      // 进度条：已备齐比例。
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width(Const.FULL_PERCENT)
          .height(6)
          .borderRadius(3)
          .backgroundColor(Const.NIGHT_CARD_BG_LIGHT)
        Row()
          .width(`${this.readyCount() / gearList.length * Const.FULL_PERCENT_NUMBER}%`)
          .height(6)
          .borderRadius(3)
          .backgroundColor(Const.NIGHT_ACCENT)
          .animation({ duration: Const.FUNC_AREA_ANIMATION, curve: Curve.EaseInOut })
      }
      .width(Const.FULL_PERCENT)
      .height(6)

      ForEach(gearList, (item: IGearItem, index: number) => {
        this.buildGearItem(item, index)
      }, (item: IGearItem) => item.name)
    }
    .width(Const.FULL_PERCENT)
    .padding(Const.CARD_PADDING)
    .borderRadius(Const.CARD_RADIUS)
    .backgroundColor(Const.NIGHT_CARD_BG)
    .border({ width: 1, color: Const.NIGHT_DIVIDER })
  }

  /**
   * 单条装备：勾选框 + 名称 + 「必带」标记 + 说明。
   */
  @Builder
  buildGearItem(item: IGearItem, index: number) {
    Row({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Circle({ width: 20, height: 20 })
          .fill(this.checked[index] ? Const.NIGHT_ACCENT : Color.Transparent)
          .stroke(this.checked[index] ? Const.NIGHT_ACCENT : Const.NIGHT_TEXT_SUB)
          .strokeWidth(1.5)
        if (this.checked[index]) {
          Text('✓')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0B1426')
        }
      }
      .width(20)
      .height(20)

      Column({ space: 3 }) {
        Row({ space: 6 }) {
          Text(item.name)
            .fontSize(13)
            .fontColor(this.checked[index] ? Const.NIGHT_TEXT : '#C2CEE0')
          if (item.required) {
            Text('必带')
              .fontSize(9)
              .fontColor(Const.KIND_DANGER_COLOR)
              .border({ width: 1, color: Const.KIND_DANGER_COLOR })
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
              .borderRadius(6)
          }
        }
        .width(Const.FULL_PERCENT)

        Text(item.reason)
          .fontSize(11)
          .fontColor(Const.NIGHT_TEXT_SUB)
          .lineHeight(17)
          .width(Const.FULL_PERCENT)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      this.toggleGear(index);
    })
  }

  /**
   * 安全须知卡片：点击标题展开说明。
   */
  @Builder
  buildSafetyCard() {
    Column({ space: 10 }) {
      Text('安全须知')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Const.NIGHT_TEXT)
        .width(Const.FULL_PERCENT)

      ForEach(safetyTips, (tip: ISafetyTip, index: number) => {
        Column({ space: 6 }) {
          Row({ space: 8 }) {
            Text(`${index + 1}`)
              .fontSize(10)
              .fontColor(Const.NIGHT_ACCENT)
              .backgroundColor(Const.NIGHT_CARD_BG_LIGHT)
              .width(18)
              .height(18)
              .textAlign(TextAlign.Center)
              .borderRadius(9)
            Text(tip.title)
              .fontSize(13)
              .fontColor(Const.NIGHT_TEXT)
            Blank()
            Text(this.expandedTip === index ? '−' : '+')
              .fontSize(14)
              .fontColor(Const.NIGHT_TEXT_SUB)
          }
          .width(Const.FULL_PERCENT)

          if (this.expandedTip === index) {
            Text(tip.content)
              .fontSize(12)
              .fontColor(Const.NIGHT_TEXT_SUB)
              .lineHeight(18)
              .width(Const.FULL_PERCENT)
              .padding({ left: 26 })
          }
        }
        .width(Const.FULL_PERCENT)
        .onClick(() => {
          this.toggleTip(index);
        })
      }, (tip: ISafetyTip) => tip.title)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding(Const.CARD_PADDING)
    .borderRadius(Const.CARD_RADIUS)
    .backgroundColor(Const.NIGHT_CARD_BG)
    .border({ width: 1, color: Const.NIGHT_DIVIDER })
  }
}
