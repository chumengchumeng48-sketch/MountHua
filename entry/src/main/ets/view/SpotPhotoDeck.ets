/**
 * 详情页「沿途影像」横向卡组（对应老师参考工程的 ImageAnimation 组件）。
 *
 * 一排卡片横向铺开，只有一张是「当前」的：它最大、最亮、带描边，两侧按
 * 环上距离逐级变窄、外移、变淡；横向滑动或点侧边的卡就换到那一张上去，
 * 当前那张被点一下则回调父组件打开大图预览。
 *
 * 与 Tab2 的环形卡组是**同一套思路**（环上距离 → 宽度 / 位移 / 层级），
 * 差别有三处，都是有意的：
 *   1. 只横向排、不绕圈：卡组一共 5 张（本站 + 前后各 2 站），
 *      滑到最边上就停住，不会转回来 —— 影像的先后顺序是有意义的；
 *   2. 不做模糊、不淡到看不见：照片是这一块的内容本身，糊了就白给；
 *   3. 位移按「占卡组宽度的百分比」算（不写死 vp），换屏幕不会挤出屏幕外。
 *
 * 尺寸不写死：卡片宽度按卡组宽度的百分比给，卡面高度由卡面宽高比反算，
 * 卡组容器高度 = 前卡高度 + 标注区高度（见 SpotPhotoDeck.deckHeight）。
 */
import { CommonConstants as Const } from '../commons/constants/CommonConstants';

@Component
export struct SpotPhotoDeck {
  /**
   * 照片列表（按夜爬顺序：前 N 站 → 本站 → 后 N 站）。
   */
  @Prop photos: Resource[] = [];
  /**
   * 与 photos 一一对应的站点名。
   */
  @Prop names: string[] = [];
  /**
   * 与 photos 一一对应的站点序号（卡面角标）。
   */
  @Prop seqs: number[] = [];
  /**
   * 进页面时停在第几张（本站的位置）。
   */
  @Prop focusIndex: number = 0;
  /**
   * 点当前那张卡的回调（父组件弹大图预览）。
   */
  onPreview: (index: number) => void = () => {
  };

  /**
   * 当前（最前面）那张卡的下标。
   */
  @State currentIndex: number = 0;
  /**
   * 卡组容器实测宽度（vp）：卡片宽度与位移都由它按百分比换算。
   */
  @State deckWidth: number = 0;

  aboutToAppear(): void {
    // 一进来就把视角停在本站那张，而不是从最前面的邻站开始滑。
    this.currentIndex = Math.max(0, Math.min(this.focusIndex, this.photos.length - 1));
  }

  /**
   * 环上距离：第 index 张卡离「当前那张」几档（正数在左、负数在右）。
   */
  private coefficientOf(index: number): number {
    return this.currentIndex - index;
  }

  /**
   * 第 index 张卡宽度占卡组宽度的百分比：当前那张最宽，每远一档窄一档。
   */
  private widthPercentOf(index: number): number {
    return Const.DETAIL_DECK_AHEAD_WIDTH
      - Const.DETAIL_DECK_WIDTH_STEP * Math.abs(this.coefficientOf(index));
  }

  /**
   * 第 index 张卡的实际宽度（vp）。
   */
  private cardWidthOf(index: number): number {
    return this.deckWidth * this.widthPercentOf(index) / Const.FULL_PERCENT_NUMBER;
  }

  /**
   * 当前那张卡的高度（vp）：宽度除以卡面宽高比。
   */
  private frontCardHeight(): number {
    return this.deckWidth * Const.DETAIL_DECK_AHEAD_WIDTH / Const.FULL_PERCENT_NUMBER
      / Const.DETAIL_DECK_CARD_ASPECT;
  }

  /**
   * 卡组容器高度（vp）：前卡高度 + 卡下方标注区高度。
   */
  private deckHeight(): number {
    return this.frontCardHeight() + Const.DETAIL_DECK_TEXT_BLOCK;
  }

  /**
   * 第 index 张卡的横向位移（vp）。
   *
   * 环上系数为正说明它排在当前那张**前面**（更早的站）→ 往左铺；为负则往右铺。
   * 位移取绝对值（±1 档一档、±2 档一档），不再乘一次档数 —— 常量本身就是
   * 「这一档离中心多远」。
   */
  private offsetXOf(index: number): number {
    const coefficient: number = this.coefficientOf(index);
    const distance: number = Math.abs(coefficient);
    if (distance === 0) {
      return 0;
    }
    const shiftPercent: number = distance === 1
      ? Const.DETAIL_DECK_NEAR_SHIFT
      : Const.DETAIL_DECK_FAR_SHIFT;
    // 系数为正 → 往左（负位移），为负 → 往右。
    const direction: number = coefficient > 0 ? -1 : 1;
    return direction * shiftPercent * this.deckWidth / Const.FULL_PERCENT_NUMBER;
  }

  /**
   * 第 index 张卡是否在可视范围内（超出档位的淡出叠到后面）。
   */
  private isVisible(index: number): boolean {
    return Math.abs(this.coefficientOf(index)) <= Const.DETAIL_DECK_NEAR_RANGE;
  }

  /**
   * 是否是当前那张。
   */
  private isAhead(index: number): boolean {
    return index === this.currentIndex;
  }

  /**
   * 换到第 index 张（带动画）。
   *
   * 点侧边的卡是「直接翻到那张」，横滑是「一格一格挪」，所以这里算出一个
   * 收敛过的目标下标再赋值，避免越界。
   */
  private focusTo(index: number): void {
    const target: number = Math.max(0, Math.min(this.photos.length - 1, index));
    if (target === this.currentIndex) {
      return;
    }
    this.getUIContext().animateTo({
      duration: Const.DETAIL_DECK_ANIMATION,
      curve: Curve.EaseOut
    }, () => {
      this.currentIndex = target;
    });
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      ForEach(this.photos, (photo: Resource, index: number) => {
        Column({ space: 6 }) {
          // 统一高度的「图片带」：各档卡面大小不同，但都在这一带里垂直居中，
          // 于是下面那行站名标注天然对齐成一行。
          // 直接把 Image 当卡的根节点会让小卡的标注往上飘 —— 卡片是按自身高度
          // 参与居中排列的，越小的卡越靠中间，标注高度就参差不齐。
          Stack({ alignContent: Alignment.Center }) {
            Image(photo)
              .width(Const.FULL_PERCENT)
              .aspectRatio(Const.DETAIL_DECK_CARD_ASPECT)
              .objectFit(ImageFit.Cover)
              .interpolation(ImageInterpolation.Medium)
              .draggable(false)
              // 与 Tab2 卡组、地图页卡片共用同一个圆角，全站卡面观感统一。
              .borderRadius(Const.DECK_RADIUS)
              .border({
                width: this.isAhead(index) ? Const.DECK_ACTIVE_BORDER : 1,
                color: this.isAhead(index) ? this.aheadBorderColor() : Const.NIGHT_DIVIDER
              })
              .shadow({
                radius: Const.DECK_SHADOW_RADIUS,
                color: Const.DECK_SHADOW_COLOR,
                offsetX: 0,
                offsetY: Const.DECK_SHADOW_OFFSET_Y
              })
          }
          .width(Const.FULL_PERCENT)
          .height(this.frontCardHeight())

          // 卡下方的站名标注：当前那张写全，两侧只留序号，越远越淡。
          Text(this.labelOf(index))
            .fontSize(11)
            .fontWeight(this.isAhead(index) ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.isAhead(index) ? Const.NIGHT_ACCENT : Const.NIGHT_TEXT_SUB)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(Const.FULL_PERCENT)
            .textAlign(TextAlign.Center)
        }
        .width(this.cardWidthOf(index))
        .offset({ x: this.offsetXOf(index), y: 0 })
        .zIndex(Const.DETAIL_DECK_NEAR_RANGE - Math.abs(this.coefficientOf(index)))
        .opacity(this.isVisible(index) ? 1 : 0)
        // 淡到看不见的那几张不该还能点到：它们的 zIndex 已经压到最底，
        // 但命中测试不看 zIndex，所以显式关掉。
        .hitTestBehavior(this.isVisible(index) ? HitTestMode.Default : HitTestMode.None)
        .onClick(() => {
          if (this.isAhead(index)) {
            // 点当前那张 = 看大图
            this.onPreview(index);
            return;
          }
          // 点侧边的卡 = 直接翻到那张
          this.focusTo(index);
        })
      },
        // 键值带上卡组实测宽度：容器量到真实大小后重建一次卡片，
        // 尺寸不用等下一次状态变化才生效（与 Tab2 卡组同一处理）。
        (photo: Resource, index: number) => `${index}@${Math.round(this.deckWidth)}`)
    }
    .width(Const.FULL_PERCENT)
    .height(this.deckHeight())
    .clip(true)
    .onAreaChange((oldVal: Area, newVal: Area) => {
      const width: number = Number(newVal.width);
      if (width > 0) {
        this.deckWidth = width;
      }
    })
    .gesture(
      // 横向滑动切换：位移超过阈值才算数，免得手一抖就翻页。
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionEnd((event: GestureEvent) => {
          if (Math.abs(event.offsetX) < Const.DETAIL_DECK_SWIPE_THRESHOLD) {
            return;
          }
          // 往左滑（offsetX < 0）看更晚的站（下标变大）。
          this.focusTo(event.offsetX < 0 ? this.currentIndex + 1 : this.currentIndex - 1);
        })
    )
  }

  /**
   * 当前那张卡的描边色。
   *
   * 这里给的是主题强调色，不是站点类型色 —— 卡组只拿到照片与站名
   * （没有完整站点对象），为一张卡的描边再传一份配色进来不划算；
   * 而且一屏只有一张卡有描边，用强调色反而与整页更统一。
   */
  private aheadBorderColor(): string {
    return Const.NIGHT_ACCENT;
  }

  /**
   * 卡下方的标注文案：当前那张「序号 · 站名」，两侧只写序号。
   */
  private labelOf(index: number): string {
    const seq: number = index < this.seqs.length ? this.seqs[index] : index + 1;
    if (!this.isAhead(index)) {
      return `${seq}`;
    }
    const name: string = index < this.names.length ? this.names[index] : '';
    return `${seq} · ${name}`;
  }
}
