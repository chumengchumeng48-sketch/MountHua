import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import { stations, routeSummary, stationKindColor, stationProgress, climbProgress, IStation } from '../viewmodel/MapModel';
import { sunriseInfo } from '../viewmodel/PlanModel';

/**
 * Tab3「夜爬时刻」页面组件。
 *
 * 把 15 个站点按时间排成一条竖向时间轴：
 * - 左侧是建议到达时刻（关键站点用暖黄色突出）；
 * - 中间是时间轴（连线上圆点，圆点按站点类型配色，当前所在站点高亮放大）；
 * - 右侧是站点名、海拔与累计里程。
 *
 * 顶部给出当前时刻与夜爬进度（按 21:30 出发、05:20 登顶换算，跨午夜处理），
 * 底部是东峰观日信息与夜爬提示。
 */
@Component
export struct PlanView {
  /**
   * 当前时刻文本（HH:MM）。
   */
  @State clockText: string = '';
  /**
   * 当前夜爬进度（0 ~ 1）。
   */
  @State climbRate: number = 0;
  /**
   * 当前已过站点序号（0 = 尚未出发）。
   */
  @State currentSeq: number = 0;

  aboutToAppear(): void {
    const now = new Date();
    this.clockText = `${this.pad2(now.getHours())}:${this.pad2(now.getMinutes())}`;
    this.climbRate = climbProgress(now);
    let seq = 0;
    for (let i = 0; i < stations.length; i++) {
      if (this.climbRate >= stationProgress(stations[i])) {
        seq = stations[i].seq;
      }
    }
    this.currentSeq = seq;
  }

  private pad2(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  /**
   * 预计用时文案。
   */
  private durationText(): string {
    const h = Math.floor(routeSummary.durationMinutes / 60);
    const m = routeSummary.durationMinutes % 60;
    return `${h} 时 ${m} 分`;
  }

  private progressLabel(): string {
    if (this.climbRate <= 0) {
      return `未出发 · 今晚 ${routeSummary.startTime} 集合`;
    }
    if (this.climbRate >= 1) {
      return '已登顶 · 东峰观日台';
    }
    return `行进中 ${Math.round(this.climbRate * 100)}%`;
  }

  build() {
    Column() {
      // 页面标题。
      Row({ space: 8 }) {
        Column({ space: 4 }) {
          Text(Const.PLAN_TITLE)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Const.NIGHT_TEXT)
          Text(`${routeSummary.startTime} 出发 → ${routeSummary.summitTime} 登顶 · 全程 ${this.durationText()}`)
            .fontSize(12)
            .fontColor(Const.NIGHT_TEXT_SUB)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Column({ space: 2 }) {
          Text(this.clockText)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Const.NIGHT_ACCENT)
          Text(this.progressLabel())
            .fontSize(10)
            .fontColor(Const.NIGHT_TEXT_SUB)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width(Const.FULL_PERCENT)
      .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN, top: 14, bottom: 10 })

      Scroll() {
        Column({ space: 0 }) {
          ForEach(stations, (s: IStation, idx: number) => {
            this.buildTimelineRow(s, idx)
          }, (s: IStation) => `plan${s.seq}`)
          this.buildSunriseCard()
          this.buildNoticeCard()
        }
        .width(Const.FULL_PERCENT)
        .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN, bottom: 18 })
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
   * 时间轴的一行：时刻 + 轴线圆点 + 站点信息。
   */
  @Builder
  buildTimelineRow(s: IStation, idx: number) {
    Row() {
      // 时间列。
      Column() {
        Text(s.time)
          .fontSize(13)
          .fontWeight(s.key ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(s.key ? Const.NIGHT_ACCENT : Const.NIGHT_TEXT_SUB)
      }
      .width(52)
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.Center)
      .height(Const.TIMELINE_ROW_MIN_HEIGHT)

      // 轴线列：上段线 + 圆点 + 下段线（首尾两行各隐藏一段，避免线头外露）。
      Column() {
        Rect()
          .width(2)
          .height(23)
          .fill(idx === 0 ? Color.Transparent : Const.NIGHT_DIVIDER)
        Stack({ alignContent: Alignment.Center }) {
          Circle({ width: this.dotSize(s), height: this.dotSize(s) })
            .fill(this.currentSeq === s.seq ? stationKindColor(s.kind) : Const.NIGHT_BG)
            .stroke(stationKindColor(s.kind))
            .strokeWidth(this.currentSeq === s.seq ? 3 : 2)
        }
        .width(Const.TIMELINE_DOT_SIZE + 4)
        .height(16)
        Rect()
          .width(2)
          .height(23)
          .fill(idx === stations.length - 1 ? Color.Transparent : Const.NIGHT_DIVIDER)
      }
      .width(24)
      .height(Const.TIMELINE_ROW_MIN_HEIGHT)
      .justifyContent(FlexAlign.Start)

      // 内容列。
      Column({ space: 3 }) {
        Row({ space: 6 }) {
          Text(s.name)
            .fontSize(14)
            .fontWeight(this.currentSeq === s.seq ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.currentSeq === s.seq ? Const.NIGHT_ACCENT : Const.NIGHT_TEXT)
          if (this.currentSeq === s.seq && this.climbRate > 0 && this.climbRate < 1) {
            Text('当前')
              .fontSize(9)
              .fontColor('#0B1426')
              .backgroundColor(Const.NIGHT_ACCENT)
              .padding({ left: 5, right: 5, top: 1, bottom: 1 })
              .borderRadius(7)
          }
        }
        .width(Const.FULL_PERCENT)

        Text(`海拔 ${s.altitude} m · 累计 ${s.distance} km`)
          .fontSize(11)
          .fontColor(Const.NIGHT_TEXT_SUB)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .height(Const.TIMELINE_ROW_MIN_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 10 })
    }
    .width(Const.FULL_PERCENT)
    .height(Const.TIMELINE_ROW_MIN_HEIGHT)
  }

  private dotSize(s: IStation): number {
    return this.currentSeq === s.seq ? Const.TIMELINE_DOT_SIZE + 4 : Const.TIMELINE_DOT_SIZE;
  }

  /**
   * 东峰观日卡片。
   */
  @Builder
  buildSunriseCard() {
    Column({ space: 10 }) {
      // 东峰观日台实景照片。
      Image(stations[stations.length - 1].photo)
        .width(Const.FULL_PERCENT)
        .height(Const.SPOT_PHOTO_HEIGHT)
        .objectFit(ImageFit.Cover)
        .borderRadius(Const.SPOT_PHOTO_RADIUS)
        .draggable(false)
        .interpolation(ImageInterpolation.Medium)

      Row({ space: 8 }) {
        Text('日出')
          .fontSize(11)
          .fontColor('#0B1426')
          .backgroundColor(Const.NIGHT_ACCENT)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(9)
        Text(sunriseInfo.spot)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Const.NIGHT_TEXT)
        Blank()
        Text(`海拔 ${sunriseInfo.altitude} m`)
          .fontSize(11)
          .fontColor(Const.NIGHT_TEXT_SUB)
      }
      .width(Const.FULL_PERCENT)

      Row() {
        this.buildInfoItem('建议占位', sunriseInfo.arriveTime)
        this.buildInfoItem('日出时段', sunriseInfo.sunriseRange)
      }
      .width(Const.FULL_PERCENT)

      Text(sunriseInfo.tip)
        .fontSize(12)
        .fontColor('#C2CEE0')
        .lineHeight(19)
        .width(Const.FULL_PERCENT)
    }
    .width(Const.FULL_PERCENT)
    .padding(Const.CARD_PADDING)
    .borderRadius(Const.CARD_RADIUS)
    .backgroundColor(Const.NIGHT_CARD_BG)
    .border({ width: 1, color: Const.NIGHT_DIVIDER })
    .margin({ top: 14 })
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Column({ space: 3 }) {
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Const.NIGHT_ACCENT)
      Text(label)
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 提示卡片。
   */
  @Builder
  buildNoticeCard() {
    Column({ space: 6 }) {
      Text('夜爬提示')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(Const.NIGHT_TEXT)
      Text('· 时刻为按普通体力推算的示意值，实际会因队伍速度、排队而整体后移。')
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .lineHeight(18)
      Text('· 山上补给点夜里多数关闭，青柯坪可补水，务必自带饮水与高热量食物。')
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .lineHeight(18)
      Text('· 雨雪、大风天气不要夜爬，险段湿滑风险极高。')
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .lineHeight(18)
      Text(Const.SPOT_PHOTO_CREDIT)
        .fontSize(10)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .opacity(0.8)
        .lineHeight(18)
        .margin({ top: 2 })
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding(Const.CARD_PADDING)
    .borderRadius(Const.CARD_RADIUS)
    .backgroundColor(Const.NIGHT_CARD_BG)
    .border({ width: 1, color: Const.NIGHT_DIVIDER })
    .margin({ top: Const.LIST_ITEM_GAP })
  }
}
