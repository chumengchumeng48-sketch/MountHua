import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import Logger from '../commons/utils/Logger';
import ZonesItem from '../viewmodel/ZonesItem';
import zonesViewModel from '../viewmodel/ZonesViewModel';

/**
 * 卡面底部渐变遮罩的颜色带（透明 → 夜色）。
 *
 * 单独写成带元组类型的常量，而不是直接写在 linearGradient 里：
 * ArkTS 对字面量数组的类型推断比 TS 严格，显式声明 Array<[ResourceColor, number]>
 * 可以避免 "not assignable" 的编译错误。
 */
const DECK_GRADIENT_COLORS: Array<[ResourceColor, number]> = [
  [Const.DECK_GRADIENT_TOP, 0.0],
  [Const.DECK_GRADIENT_MID, 0.55],
  [Const.DECK_GRADIENT_BOTTOM, 1.0]
];

/**
 * Tab2「沿途站点」页面组件 —— 环形卡组样式（对齐老师参考工程的 Zones 页面）。
 *
 * 15 张卡片排成一圈，只有一张是「最前面」的：它最大、最清晰、带完整文字；
 * 其余卡片按「在环上离最前面那张有多远」逐层错开 —— 越远越窄、越模糊、
 * 越淡、越靠后（zIndex 越小），形成一个可以一直转下去的卡组。
 *
 * 与老师参考代码的对应关系（方法名与结构保持一致，便于对照）：
 *   getImgCoefficients(index)   环上距离（含绕圈回绕）
 *   getOffsetY(index)           纵向错排位移 + 跟手位移
 *   StartAnimation(isUp)        往上 / 往下转一格（含首尾回绕）
 *   handlePanGesture(offsetY)   小位移跟手、超过阈值转一格（一次拖动只转一格）
 *   aheadIndex / changedIndex   最前面的下标 / 「一次拖动只切一格」的闩
 * 只有一处改名：老师把跟手位移叫 marginBottom，这里叫 panOffset —— 它加在
 * .offset() 上、不参与布局，叫 margin 会让人以为会把父容器撑开。
 *
 * 与参考代码的两处有意差异：
 *   1. 尺寸不写死。参考代码把卡宽写成 '86%'、竖向错排写成 100 / 180（vp）；
 *      这里卡宽仍按卡组宽度的百分比，但基准大小会同时受「按高度装得下」的上限
 *      约束，竖向错排也改成按基准卡高的比例算，免得换个屏幕就叠不上。
 *   2. 卡上带文字。参考代码的卡面只有图片，而站名 / 海拔里程 / 简介是这一页的
 *      核心信息，所以文字层只画在最前面那张卡上（其余卡整层透明度为 0）。
 *
 * 数据全部经 ZonesViewModel（单例）取：站点、类型名、类型配色、海拔里程文案、
 * 当前时刻所在站点都已装配好，页面不做任何换算与派生。
 */
@Component
export struct ZonesView {
  /**
   * 「一次拖动只允许切换一格」的闩（老师参考代码的 changedIndex）。
   *
   * 手势的 onActionUpdate 每帧都来一次，手指跨过阈值后会连续满足切换条件；
   * 这个闩保证一次拖动最多只转一格，想再转要松手重来。
   */
  private changedIndex: boolean = true;
  /**
   * 最前面那张卡片的下标（老师参考代码的 aheadIndex）。
   */
  @State aheadIndex: number = 0;
  /**
   * 跟手拖动的位移（老师参考代码的 marginBottom）。
   *
   * 手指还没跨过切换阈值时，整摞卡跟着手指走一点，让「拖得动」这件事可见。
   */
  @State panOffset: number = 0;
  /**
   * 卡组容器实测宽度 / 高度（单位：vp），用来反算卡牌大小。
   */
  @State deckWidth: number = 0;
  @State deckHeight: number = 0;
  /**
   * 当前已过站点的序号（按当前时刻计算，1 起，用于「当前位置」标记）。
   */
  @State currentSeq: number = 0;
  /**
   * 当前夜爬进度（0 ~ 1）。
   */
  @State climbRate: number = 0;
  /**
   * 站点装配结果（静态数据，不参与状态刷新）。
   */
  private readonly list: ZonesItem[] = zonesViewModel.getZonesList();

  aboutToAppear(): void {
    const now: Date = new Date();
    this.climbRate = zonesViewModel.getClimbRate(now);
    this.currentSeq = zonesViewModel.getCurrentZone(this.climbRate).id;
    // 默认把「当前时刻所在的那一站」转到最前面：夜爬途中打开就是「我现在到哪了」。
    // 未出发时进度为 0，自动落在第 1 站玉泉院，与前几页的开场口径一致。
    this.aheadIndex = Math.max(0, this.currentSeq - 1);
  }

  build() {
    Column() {
      this.buildHeader()

      // 卡组：所有卡片都居中堆叠，靠各自的 offset / 宽度 / zIndex 排成一圈。
      Stack({ alignContent: Alignment.Center }) {
        ForEach(this.list, (item: ZonesItem, index?: number) => {
          Stack() {
            // ① 实景照片：越远越模糊；按 DECK_PHOTO_OVERSCAN 放大，
            //    把模糊产生的虚边挤出可视区，免得卡片边缘发灰。
            Image(item.photo)
              .width(Const.FULL_PERCENT)
              .height(Const.FULL_PERCENT)
              .objectFit(ImageFit.Cover)
              .interpolation(ImageInterpolation.Medium)
              .draggable(false)
              .scale({ x: Const.DECK_PHOTO_OVERSCAN, y: Const.DECK_PHOTO_OVERSCAN })
              .blur(this.blurOf(this.distanceOf(index)))

            // ② 暗色渐变遮罩：照片压暗，保证站名与数据读得清。
            Column()
              .width(Const.FULL_PERCENT)
              .height(Const.FULL_PERCENT)
              .linearGradient({
                angle: Const.DECK_GRADIENT_ANGLE,
                colors: DECK_GRADIENT_COLORS
              })

            // ③ 文字层：只有最前面那张卡显示（其余整层透明度为 0），
            //    所以切换时是文字淡入淡出，而不是硬跳。
            Column() {
              Row({ space: 6 }) {
                // 序号徽标，按站点类型配色（配色由显示模型装配时给出）。
                Stack({ alignContent: Alignment.Center }) {
                  Circle({ width: Const.DECK_BADGE_SIZE, height: Const.DECK_BADGE_SIZE })
                    .fill(item.backgroundColor)
                  Text(`${item.id}`)
                    .fontSize(11)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#0B1426')
                }
                .width(Const.DECK_BADGE_SIZE)
                .height(Const.DECK_BADGE_SIZE)

                Text(item.subTitle)
                  .fontSize(10)
                  .fontColor(item.backgroundColor)
                  .border({ width: 1, color: item.backgroundColor })
                  .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                  .borderRadius(7)

                if (this.isClimbing() && this.currentSeq === item.id) {
                  Text(Const.ZONES_CURRENT_TAG)
                    .fontSize(10)
                    .fontColor('#0B1426')
                    .backgroundColor(Const.NIGHT_ACCENT)
                    .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                    .borderRadius(7)
                }
                Blank()
                Text(item.arriveTime)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Const.NIGHT_ACCENT)
              }
              .width(Const.FULL_PERCENT)

              Blank()

              Column({ space: 3 }) {
                Text(item.title)
                  .fontSize(19)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.metaText)
                  .fontSize(10)
                  .fontColor('#C2CEE0')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.intro)
                  .fontSize(10)
                  .fontColor(Const.NIGHT_TEXT_SUB)
                  .lineHeight(15)
                  .maxLines(Const.DECK_INTRO_LINES)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 2 })

                // 详情页入口提示。
                // 这层文字只画在最前面那张卡上（整层透明度为 0），
                // 所以这行提示天然只出现在可点进详情的那张卡上。
                Text(Const.DETAIL_ENTER_HINT)
                  .fontSize(10)
                  .fontColor(Const.NIGHT_ACCENT)
                  .margin({ top: 4 })
              }
              .width(Const.FULL_PERCENT)
              .alignItems(HorizontalAlign.Start)
            }
            .width(Const.FULL_PERCENT)
            .height(Const.FULL_PERCENT)
            .padding(Const.DECK_CARD_PADDING)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(HorizontalAlign.Start)
            .opacity(this.isAhead(index) ? 1 : 0)
            // 文字层不参与命中测试，点击一定落到卡片本体的 onClick 上。
            .hitTestBehavior(HitTestMode.None)
          }
          .width(this.widthOf(index))
          .height(this.widthOf(index) / Const.DECK_CARD_ASPECT)
          .borderRadius(Const.DECK_RADIUS)
          .clip(true)
          .backgroundColor(Const.NIGHT_CARD_BG)
          .border({
            width: this.isAhead(index) ? Const.DECK_ACTIVE_BORDER : 1,
            color: this.isAhead(index) ? item.backgroundColor : Const.NIGHT_DIVIDER
          })
          .shadow({
            radius: Const.DECK_SHADOW_RADIUS,
            color: Const.DECK_SHADOW_COLOR,
            offsetX: 0,
            offsetY: Const.DECK_SHADOW_OFFSET_Y
          })
          .opacity(this.opacityOf(this.distanceOf(index)))
          .offset({ x: 0, y: this.getOffsetY(index) })
          .zIndex(this.zIndexOf(index))
          .onClick(() => {
            this.onCardTap(index);
          })
        },
          // 键值带上卡组实测尺寸：容器量到真实大小后重建一次卡片，
          // 尺寸不用等下一次状态变化才生效（手势过程中尺寸不变，动画不受影响）。
          (item: ZonesItem) => `${item.id}@${Math.round(this.deckWidth)}x${Math.round(this.deckHeight)}`)
      }
      .width(Const.FULL_PERCENT)
      .layoutWeight(1)
      .clip(true)
      .onAreaChange((oldVal: Area, newVal: Area) => {
        // 尺寸由父组件（layoutWeight）决定，与卡片自身大小无关，所以不会形成布局循环。
        const width: number = Number(newVal.width);
        const height: number = Number(newVal.height);
        if (width > 0 && height > 0) {
          this.deckWidth = width;
          this.deckHeight = height;
        }
      })
      .gesture(
        // 上下拖动切换：小位移跟手，跨过阈值转一格（一次拖动只转一格）。
        PanGesture({ direction: PanDirection.Vertical })
          .onActionStart((event: GestureEvent) => {
            // 手势开始 = 重新上闩，本次拖动又可以切换一次（老师参考代码同款）。
            this.changedIndex = false;
            this.handlePanGesture(event.offsetY);
          })
          .onActionUpdate((event: GestureEvent) => {
            this.handlePanGesture(event.offsetY);
          })
          .onActionEnd(() => {
            // 松手：没跨过阈值的跟手位移弹回原位（跨过了则由转格动画一并归零）。
            this.getUIContext().animateTo({ duration: Const.DECK_ANIMATION }, () => {
              this.panOffset = 0;
            });
          })
      )

      this.buildFooter()
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .backgroundColor(Const.NIGHT_BG)
  }

  /**
   * 页头：标题 + 「第 n / N 站」角标 + 全程与时刻两行副标题。
   */
  @Builder
  buildHeader() {
    Column({ space: 4 }) {
      Row({ space: 8 }) {
        Text(Const.INTRODUCTION_TITLE)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Const.NIGHT_TEXT)
        Blank()
        Text(`${this.aheadIndex + 1} / ${this.list.length}`)
          .fontSize(11)
          .fontColor(Const.NIGHT_ACCENT)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(10)
          .backgroundColor(Const.NIGHT_CARD_BG)
          .border({ width: 1, color: Const.NIGHT_DIVIDER })
      }
      .width(Const.FULL_PERCENT)

      Text(this.buildSubTitle())
        .fontSize(12)
        .fontColor(Const.NIGHT_TEXT_SUB)

      Text(this.buildTimeLine())
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .opacity(0.85)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN, top: 14, bottom: 8 })
  }

  /**
   * 页脚：当前站点的夜爬提示 + 实时进度 + 数据口径与照片来源说明。
   */
  @Builder
  buildFooter() {
    Column({ space: 5 }) {
      Row({ space: 8 }) {
        Text(`提示：${this.itemAt(this.aheadIndex).tip}`)
          .fontSize(11)
          .fontColor(Const.NIGHT_ACCENT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Text(Const.DECK_HINT)
          .fontSize(10)
          .fontColor(Const.NIGHT_TEXT_SUB)
      }
      .width(Const.FULL_PERCENT)

      // 行进中才显示实时位置，与地图页的进度圆点口径一致。
      if (this.isClimbing()) {
        Row({ space: 6 }) {
          Circle({ width: 6, height: 6 })
            .fill(Const.NIGHT_ACCENT)
          Text(this.buildProgressText())
            .fontSize(10)
            .fontColor(Const.NIGHT_TEXT_SUB)
        }
        .width(Const.FULL_PERCENT)
      }

      Text(Const.ZONES_DATA_NOTE)
        .fontSize(9)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .opacity(0.75)
        .width(Const.FULL_PERCENT)
      Text(Const.SPOT_PHOTO_CREDIT)
        .fontSize(9)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .opacity(0.75)
        .width(Const.FULL_PERCENT)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN, top: 6, bottom: 10 })
  }

  /**
   * 环上距离：第 index 张卡离「最前面那张」有多远（老师参考代码的 getImgCoefficients）。
   *
   * 先算 aheadIndex - index，再按卡片总数回绕 —— 因为是环形排列，
   * 最后一张的下一张就是第一张，距离超过半圈时要从另一侧算。
   *
   * 返回 0 有两种含义，靠 index === aheadIndex 区分：
   *   - 它就是要显示在最前面的那张；
   *   - 它离得太远，退到背面叠着（反正会被最前面那张完全盖住）。
   */
  private getImgCoefficients(index?: number): number {
    if (index === undefined) {
      return 0;
    }
    const coefficient: number = this.aheadIndex - index;
    const tempCoefficient: number = Math.abs(coefficient);
    // 在正常显示范围内（上下各 DECK_NEAR_RANGE 层），直接返回距离参与错排。
    if (tempCoefficient <= Const.DECK_NEAR_RANGE) {
      return coefficient;
    }
    // 超出范围：看它从另一侧绕过来有多远（15 张卡时，距离 14 就等于反向 1）。
    const tempOffset: number = this.list.length - tempCoefficient;
    if (tempOffset <= Const.DECK_NEAR_RANGE) {
      return coefficient > 0 ? -tempOffset : tempOffset;
    }
    return 0;
  }

  /**
   * 环上距离的绝对值（模糊 / 透明度 / 层级都按它衰减）。
   */
  private distanceOf(index?: number): number {
    return Math.abs(this.getImgCoefficients(index));
  }

  /**
   * 第 index 张卡片的纵向偏移（老师参考代码的 getOffsetY）。
   *
   * 错层逻辑：环上系数为正的在上面（负位移）、为负的在下面（正位移）。
   * 跟手位移按 1/(层数+1) 衰减 —— 越外层的卡跟得越少，手感上像整摞卡有阻尼。
   *
   * 错排距离直接给绝对值（±1 档 = DECK_NEAR_SHIFT 个卡高、±2 档 = DECK_FAR_SHIFT 个）。
   * 老师参考代码写的是 `-offsetIndex * 100` / `-offsetIndex * 90` —— 那里乘了一次
   * offsetIndex 本身，所以 ±2 档实际是 2 × 90 = 180；换算成卡高就是 100/258 ≈ 0.39
   * 与 180/258 ≈ 0.70，也就是下面这两个常量。
   */
  private getOffsetY(index?: number): number {
    const offsetIndex: number = this.getImgCoefficients(index);
    const tempOffset: number = Math.abs(offsetIndex);
    let offsetY: number = this.panOffset / (tempOffset + 1);
    const cardHeight: number = this.aheadCardHeight();
    // 系数为正（在上面）取负位移，为负（在下面）取正位移。
    const direction: number = offsetIndex >= 0 ? 1 : -1;
    if (tempOffset === 1) {
      offsetY -= direction * cardHeight * Const.DECK_NEAR_SHIFT;
    } else if (tempOffset === Const.DECK_NEAR_RANGE) {
      offsetY -= direction * cardHeight * Const.DECK_FAR_SHIFT;
    }
    return offsetY;
  }

  /**
   * 堆叠层级（老师参考代码的 zIndex 算式）：
   * 最前面那张最高，每远一档低一层；退到背面的卡压到最底层。
   */
  private zIndexOf(index?: number): number {
    const coefficient: number = this.getImgCoefficients(index);
    if (index !== this.aheadIndex && coefficient === 0) {
      return 0;
    }
    return Const.DECK_NEAR_RANGE - Math.abs(coefficient);
  }

  /**
   * 第 index 张卡片的宽度：基准宽度 × 该档的百分比。
   *
   * 最前面那张 = DECK_AHEAD_WIDTH%，每往外一档窄 DECK_WIDTH_STEP 个百分点；
   * 退到背面的卡用 DECK_BACK_WIDTH%（与最外一档同宽，转过去时不跳变）。
   */
  private widthOf(index?: number): number {
    return this.baseWidth() * this.widthPercentOf(index) / Const.FULL_PERCENT_NUMBER;
  }

  /**
   * 第 index 张卡片的宽度百分比。
   */
  private widthPercentOf(index?: number): number {
    const coefficient: number = this.getImgCoefficients(index);
    if (index !== this.aheadIndex && coefficient === 0) {
      return Const.DECK_BACK_WIDTH;
    }
    return Const.DECK_AHEAD_WIDTH - Const.DECK_WIDTH_STEP * Math.abs(coefficient);
  }

  /**
   * 100% 基准宽度（卡片宽度都按它的百分比算）。
   *
   * 取两个上限的较小值：
   *   1. 整摞卡（含最外那两张）必须装得下卡组可用高度 —— 先从卡组高度反算出
   *      最前面那张卡的高度，再折算成 100% 宽度；
   *   2. 整摞卡不超过卡组宽度（即 100% = 卡组宽度）。
   * 容器还没量到尺寸时返回 0（此时卡片尺寸为 0，量到后立刻重算）。
   */
  private baseWidth(): number {
    if (this.deckWidth <= 0 || this.deckHeight <= 0) {
      return 0;
    }
    const byHeight: number = this.deckHeight * Const.DECK_HEIGHT_RATIO / this.deckExtentRatio()
      * Const.DECK_CARD_ASPECT * Const.FULL_PERCENT_NUMBER / Const.DECK_AHEAD_WIDTH;
    return Math.min(byHeight, this.deckWidth);
  }

  /**
   * 最前面那张卡的高度：纵向错排的位移、整摞总占用都以它为基准。
   */
  private aheadCardHeight(): number {
    return this.baseWidth() * Const.DECK_AHEAD_WIDTH / Const.FULL_PERCENT_NUMBER
      / Const.DECK_CARD_ASPECT;
  }

  /**
   * 整摞卡的纵向总占用（单位：最前面那张卡的高）
   * = 2 ×（最外一档的错排位移 + 该档卡牌的半高）。
   *
   * 有了它才能从卡组可用高度反算卡的大小，保证整摞一定装得下。
   */
  private deckExtentRatio(): number {
    const backCardHeight: number = Const.DECK_BACK_WIDTH / Const.DECK_AHEAD_WIDTH;
    return Const.DOUBLE_OR_HALF *
      (Const.DECK_FAR_SHIFT + backCardHeight / Const.DOUBLE_OR_HALF);
  }

  /**
   * 环上距离 n 档的模糊半径。
   */
  private blurOf(n: number): number {
    return Math.min(n * Const.DECK_BLUR_STEP, Const.DECK_BLUR_MAX);
  }

  /**
   * 环上距离 n 档的不透明度。
   */
  private opacityOf(n: number): number {
    return Math.max(0, 1 - n * Const.DECK_OPACITY_STEP);
  }

  /**
   * 是否是「最前面」那张（文字层与高亮描边都看它）。
   */
  private isAhead(index?: number): boolean {
    return index === this.aheadIndex;
  }

  /**
   * 把卡组往上 / 往下转一格（老师参考代码的 StartAnimation）。
   *
   * 环形回绕：往前走到最后一张就回到第一张；往回走时先加 dataLength - 1 再取余，
   * 避免出现负下标。所以要绕一整圈才会回到原处。
   *
   * 动画必须由 animateTo 驱动：所有卡片的位置 / 宽度 / 层级都由 aheadIndex 推出来，
   * 只有把它们放进同一个动画闭包，才是「转过去」而不是「啪一下换位」。
   */
  private StartAnimation(isUp: boolean): void {
    this.getUIContext().animateTo({ duration: Const.DECK_ANIMATION }, () => {
      const dataLength: number = this.list.length;
      const tempIndex: number = isUp ? this.aheadIndex + 1 : dataLength + this.aheadIndex - 1;
      this.aheadIndex = tempIndex % dataLength;
      this.panOffset = 0;
    });
  }

  /**
   * 手势处理（老师参考代码的 handlePanGesture）。
   *
   * 位移没跨过阈值：只记下跟手位移，卡片动一点但不切换；
   * 跨过阈值：转一格，并用 changedIndex 闩住 —— 一次拖动只转一格。
   */
  private handlePanGesture(offsetY: number): void {
    if (Math.abs(offsetY) < Const.DECK_SWIPE_THRESHOLD) {
      this.panOffset = offsetY;
      return;
    }
    if (this.changedIndex) {
      return;
    }
    this.changedIndex = true;
    // 上滑（offsetY < 0）看的是下一张，下滑看的是上一张。
    this.StartAnimation(offsetY < 0);
  }

  /**
   * 点卡片：最前面那张 → 进该站点的详情页；侧边的卡 → 把它转上来。
   *
   * 老师参考代码是整页一个 onClick 直接 router.pushUrl 跳详情；本项目要把
   * 「点侧边的卡就把它转上来」这个手势保留下来，所以按「是不是正面那张」分流。
   */
  private onCardTap(index?: number): void {
    if (this.isAhead(index)) {
      this.openDetail();
      return;
    }
    const coefficient: number = this.getImgCoefficients(index);
    if (coefficient === 0) {
      return;
    }
    this.StartAnimation(coefficient < 0);
  }

  /**
   * 打开当前正面那张卡的站点详情页。
   *
   * 只把站点序号传过去（页面按 id 自己去数据层取整站数据），不传整个对象：
   * 路由传参要经过序列化，塞整个 ZonesItem 既没必要也容易出问题。
   *
   * 用 `this.getUIContext().getRouter()` 而不是 `@ohos.router` 的全局 router：
   * 后者自 API 18 起已废弃，官方 `@useinstead` 指向 UIContext.Router。
   */
  private openDetail(): void {
    const target: ZonesItem = this.list[this.aheadIndex];
    const params: Record<string, number> = {};
    params[Const.ROUTER_PARAM_ID] = target.id;
    this.getUIContext().getRouter().pushUrl({ url: Const.SPOT_DETAIL_PAGE_URL, params: params })
      .catch((err: Error) => {
        Logger.error(`ZonesView open detail failed: ${err.message}`);
      });
  }

  /**
   * 取第 index 站的显示数据（下标越界由显示模型收敛）。
   */
  private itemAt(index: number): ZonesItem {
    return zonesViewModel.getZonesByIndex(index);
  }

  /**
   * 夜爬是否进行中（未出发 / 已完成时不显示实时位置）。
   */
  private isClimbing(): boolean {
    return this.climbRate > 0 && this.climbRate < 1;
  }

  /**
   * 页头副标题：站点数 · 里程 · 累计爬升。
   */
  private buildSubTitle(): string {
    const s = zonesViewModel.summary;
    return `${s.count} 个站点 · ${s.distance} km · 累计爬升 ${s.ascent} m`;
  }

  /**
   * 页头第二行：起止时刻与全程用时。
   */
  private buildTimeLine(): string {
    const s = zonesViewModel.summary;
    return `${s.startTime} 玉泉院出发 → ${s.summitTime} 东峰登顶 · 全程 ${s.durationText}`;
  }

  /**
   * 实时进度文案：已过站点 + 进度百分比。
   */
  private buildProgressText(): string {
    const title: string = this.itemAt(this.currentSeq - 1).title;
    return `${Const.ZONES_REACHED_PREFIX} ${title}（第 ${this.currentSeq} 站）· 进行中 ${Math.round(this.climbRate * 100)}%`;
  }
}
