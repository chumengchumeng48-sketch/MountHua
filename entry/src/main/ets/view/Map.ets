import Logger from '../commons/utils/Logger';
import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import { AddressItem, Location } from '../viewmodel/AddressItem';
import { PositionItem, PositionList } from '../viewmodel/PositionItem';
import {
  stations,
  stationKindName,
  routePointAt,
  climbProgress,
  reachedStationIndex
} from '../viewmodel/MapModel';
import { MapController } from '../controller/MapController';

/**
 * Tab1「路线图」页面组件（华山夜爬）。
 *
 * 结构与参考代码一致：本文件里放三个 struct ——
 * - Map：地图本体（底图 + 路线折线 + 15 个地标 + 夜爬进度点），
 *   尺寸由 onAreaChange 从父组件拿到，平移靠 offset({x: mapX, y: mapY})；
 * - CustomPanel：底部可折叠的搜索面板（折叠箭头 + 搜索框 + 站点宫格），
 *   通过 @Link 与地图共享偏移量，搜索 / 点宫格时把地图定位到该站点；
 * - PositionGrid：宫格里的单个站点（图标 + 名称）。
 *
 * 底图 ic_hs_map.png（1200 x 1600 华山夜景俯视插画：山脚玉泉院在下、主峰在上），
 * 15 个站点的坐标是在这张底图上标定的像素值，由 controller/MapController
 * 统一换算成当前地图尺寸下的坐标 —— 页面里不写任何坐标计算。
 *
 * 主题：夜爬深色。底图本身是夜景插画，面板用夜色卡片色，站点按类型配色
 * （起点绿 / 补给蓝 / 险段橙红 / 峰顶暖黄 / 关隘紫）。
 */
@Component
export struct Map {
  /**
   * 拖动地图的手势参数（参考代码的 panOption）。
   */
  private panOption: PanGestureOptions = new PanGestureOptions({
    fingers: 1,
    direction: PanDirection.All,
    distance: Const.MAP_PAN_DISTANCE
  });
  /**
   * 地图视口宽度（屏幕宽度，单位：vp）。
   */
  @State screenMapWidth: number = 0;
  /**
   * 地图视口高度（内容区高度，单位：vp）。
   */
  @State screenHeight: number = 0;
  /**
   * 地图层宽度：由底图宽高比与地图层高度换算得来（已含缩放倍数）。
   */
  @State mapWidth: number = 0;
  /**
   * 地图层高度：可视区高度 × 当前缩放倍数。
   */
  @State mapHeight: number = 0;
  /**
   * 地图层相对视口的偏移，拖动地图、捏合缩放改的都是这两个值。
   */
  @State mapX: number = 0;
  @State mapY: number = 0;
  /**
   * 当前缩放倍数：1 = 铺满可视区，最大 MAP_ZOOM_RATIO ^ ZOOM_MAX_TIMES（约 2.44）。
   */
  @State zoomMultiple: number = 1;
  /**
   * 面板是否收起：收起后地图长高铺满整屏。
   */
  @State panelCollapsed: boolean = false;
  /**
   * 路线折线点位（当前地图尺寸下的坐标）。
   */
  @State routePoints: Array<Array<number>> = [];
  /**
   * 夜爬进度（0 ~ 1）、进度文案与进度点在屏幕上的坐标。
   */
  @State climbRate: number = 0;
  @State progressText: string = '';
  @State progressX: number = 0;
  @State progressY: number = 0;
  /**
   * 地图要渲染的地标集合与样式，通过 @Provide 共享给搜索面板。
   */
  @Provide data: AddressItem = MapController.buildAddressItem();

  /**
   * 夜爬进度刷新定时器。
   */
  private climbTimer: number = -1;

  aboutToAppear(): void {
    this.refreshProgress();
    this.climbTimer = setInterval(() => {
      this.refreshProgress();
    }, Const.CLIMB_TICK_MS);
  }

  aboutToDisappear(): void {
    if (this.climbTimer >= 0) {
      clearInterval(this.climbTimer);
      this.climbTimer = -1;
    }
  }

  /**
   * 刷新夜爬进度：算出当前进度、进度文案与进度点位置。
   */
  private refreshProgress(): void {
    const progress = climbProgress(new Date());
    this.climbRate = progress;
    const point: Array<number> = MapController.calPoint(routePointAt(progress));
    this.progressX = point[0];
    this.progressY = point[1];
    if (progress <= 0) {
      this.progressText = `今晚 ${stations[0].time} 玉泉院集合 · 全程 ${Const.CLIMB_DURATION_MINUTES} 分钟`;
    } else if (progress >= 1) {
      this.progressText = '夜爬已完成 · 东峰观日台';
    } else {
      const index = reachedStationIndex(progress);
      this.progressText = `夜爬进行中 ${Math.round(progress * 100)}% · 已过 ${stations[index].short}`;
    }
  }

  /**
   * 地图可视区高度：整屏高度减去面板占用的高度。
   *
   * 未缩放时地图层正好铺满这块区域，所以它同时是「平移的边界基准」与
   * 「缩放倍率的基准」—— 放大后地图层比它大，拖动才有可移动的余量。
   */
  private viewportHeight(): number {
    const panelHeight: number = this.panelCollapsed ? 0 : Const.PANEL_TOTAL_HEIGHT;
    return Math.max(this.screenHeight - panelHeight, Const.PANEL_ARROW_HEIGHT);
  }

  /**
   * 按视口尺寸更新地图层尺寸与位置。
   *
   * 地图高度 = 可视区高度 × 当前缩放倍数：面板展开时地图正好铺满面板上方一块，
   * 15 个站点一个不落地全在可视区里；面板收起后地图长高到整屏；放大后则超出可视区，
   * 靠拖动查看。地图宽度由底图的宽高比得来：mapWidth = 底图宽 / 底图高 × mapHeight。
   */
  private updateMapSize(center: boolean): void {
    if (this.screenMapWidth <= 0 || this.screenHeight <= 0) {
      return;
    }
    const viewH: number = this.viewportHeight();
    this.mapHeight = viewH * this.zoomMultiple;
    this.mapWidth = Const.MAP_WIDTH * this.mapHeight / Const.MAP_HEIGHT;
    // 初始化组件：第二个参数给的是「可视区高度」，不是地图层高度 ——
    // 控制器拿它当平移边界与倍率基准，若传地图层高度，放大后边界跟着一起变大，
    // 怎么拖都算「没越界」，就能把地图拖出整屏留白。
    MapController.initLeftTop(this.screenMapWidth, viewH, this.mapWidth, this.mapHeight);
    if (center) {
      this.mapX = (this.screenMapWidth - this.mapWidth) / Const.DOUBLE_OR_HALF;
      this.mapY = 0;
    }
    this.mapX = MapController.clampMapX(this.mapX);
    this.mapY = MapController.clampMapY(this.mapY);
    this.data = MapController.calLandmarksPosition(this.data);
    this.routePoints = MapController.calRoutePath();
    this.refreshProgress();
  }

  /**
   * 按倍率缩放地图（参考代码的 offsetX / offsetY 算法，锚点取可视区中心）。
   *
   * 换算：设锚点在可视区内的坐标为 a、缩放前地图层偏移为 o，则锚点对应的地图内坐标是
   * (a - o)；要让它缩放后仍落在 a，即 a = o' + (a - o) × ratio，
   * 所以 o' = a - (a - o) × ratio，展开就是 o + (1 - ratio) × (a - o)，
   * 与参考代码「offsetX = (1 - ratio) * (screenMapWidth / 2 - mapX)」完全一致。
   */
  private zoomBy(ratio: number): void {
    if (ratio === 1) {
      return;
    }
    const viewH: number = this.viewportHeight();
    // 地图层的宽高按倍率「乘法累积」（参考代码同款，不做重新赋值）。
    this.mapWidth *= ratio;
    this.mapHeight *= ratio;
    MapController.initLeftTop(this.screenMapWidth, viewH, this.mapWidth, this.mapHeight);
    // 倍率由控制器按「地图层高度 / 可视区高度」反推回来，避免浮点误差累积跑偏；
    // 面板展开 / 收起时也要靠它从可视区高度重算尺寸（见 updateMapSize）。
    this.zoomMultiple = MapController.mapMultiples();
    // 根据本次缩放的比例，计算地图层的偏移（与参考代码同式）。
    // 锚点取「可视区中心」：横轴就是 screenMapWidth / 2；纵轴取可视区半高。
    // 参考代码纵轴写的是 this.mapHeight / Const.MAP_ZOOM_RATIO / 2 —— mapHeight 这时
    // 已经是缩放后的高度，除一次 ratio 得到的是「这一步之前的地图半高」，放大后这个点
    // 并不落在屏幕中心（4 档时约为可视区高度的 2.4 倍处），画面会随放大逐步下移。
    // 换成可视区半高，缩放焦点才始终钉在屏幕中心不动。
    const offsetX: number = (1 - ratio) * (this.screenMapWidth / Const.DOUBLE_OR_HALF - this.mapX);
    const offsetY: number = (1 - ratio) * (viewH / Const.DOUBLE_OR_HALF - this.mapY);
    this.mapX += offsetX;
    this.mapY += offsetY;
    this.zoomOutCheck();
  }

  /**
   * 缩放后检查地图是否超出可视边界（参考代码的 zoomOutCheck）。
   *
   * 顺便重算地标 / 路线 / 进度点：它们的坐标都由地图层尺寸换算而来；
   * 地标 ForEach 的键值里带了换算后的坐标，重算后才会重新布局。
   */
  private zoomOutCheck(): void {
    this.mapX = MapController.clampMapX(this.mapX);
    this.mapY = MapController.clampMapY(this.mapY);
    this.data = MapController.calLandmarksPosition(this.data);
    this.routePoints = MapController.calRoutePath();
    this.refreshProgress();
  }

  /**
   * 回到初始视野：缩放复位到 1 倍并居中（顶部回中按钮用）。
   */
  private resetView(): void {
    MapController.zoomToTimes(0);
    this.getUIContext().animateTo(
      { duration: Const.MAP_LOCATE_DURATION, curve: Curve.EaseOut }, () => {
        this.zoomMultiple = 1;
        this.updateMapSize(true);
      }
    );
  }

  /**
   * 面板折叠 / 展开：地图跟着长高或缩短，带过渡动画。
   */
  private onPanelToggle(collapsed: boolean): void {
    if (this.panelCollapsed === collapsed) {
      return;
    }
    this.getUIContext().animateTo(
      { duration: Const.ANIMATION_DURATION, curve: Curve.EaseOut }, () => {
        this.panelCollapsed = collapsed;
        this.updateMapSize(true);
      }
    );
  }

  /**
   * 点地图上的地标：切换选中态，面板上方的站点卡片随之更新。
   */
  private onLandmarkTap(item: Location): void {
    this.data = MapController.selectLandmark(this.data, item.seq);
    Logger.info(`Map landmark tapped: ${item.name}`);
  }

  /**
   * 取当前选中的地标（没有选中时给第一个站点，供卡片兜底）。
   */
  private currentLocation(): Location {
    const found: Location | null = MapController.selectedLocation(this.data);
    if (found === null) {
      return this.data.location[0];
    }
    return found;
  }

  /**
   * 地标的 ForEach 键值。
   *
   * 必须把「选中状态」和「换算后的坐标」一起编进键值：ForEach 只有键值变了才会
   * 重新执行子组件构建，否则切换选中站点、地图尺寸变化时，已经建好的地标组件
   * 会被直接复用，高亮和位置都不会刷新。
   */
  private landmarkKey(item: Location): string {
    return `landmark${item.seq}_${item.selected ? 1 : 0}`
      + `_${Math.round(item.positionX)}x${Math.round(item.positionY)}`;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // 地图视口：裁剪掉超出部分，拖动不会拖出留白（越界方向被钳制）。
        Stack({ alignContent: Alignment.TopStart }) {
          // 地图层：底图 + 路线 + 地标 + 进度点，整体按 mapX / mapY 平移。
          Stack({ alignContent: Alignment.TopStart }) {
            this.buildRouteLine()
            ForEach(this.data.location, (item: Location) => {
              this.buildLandmark(item)
            }, (item: Location) => this.landmarkKey(item))
            this.buildProgressDot()
          }
          .width(this.mapWidth)
          .height(this.mapHeight)
          .backgroundImage(Const.MAP_BASE_IMAGE)
          .backgroundImageSize(ImageSize.Cover)
          .offset({ x: this.mapX, y: this.mapY })

          // 顶部浮层：标题 + 夜爬进度 + 回中按钮（不跟着地图平移）。
          this.buildMapOverlay()
        }
        .width(Const.FULL_PERCENT)
        .height(Const.FULL_PERCENT)
        .backgroundColor(Const.MAP_BG_COLOR)
        .clip(true)
        // 手势组用 Exclusive：捏合、拖动、双击三者互斥，不会一边捏合一边平移。
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            // 双指捏合：每跨过一档地图放大 MAP_ZOOM_RATIO 倍，锚点取可视区中心。
            PinchGesture({ fingers: Const.MAP_FINGER_COUNT })
              .onActionStart(() => {
                // 记下本次手势开始时的档位：event.scale 每次都从 1 重新计数，
                // 档位必须以它为基准累加，否则一松手再捏就会弹回原大小。
                MapController.pinchStart();
              })
              .onActionUpdate((event: GestureEvent) => {
                MapController.pinchUpdate(event, (ratio: number) => {
                  this.zoomBy(ratio);
                });
              })
              // 捏合 / 放开结束后，重新计算边界等数据（参考代码同款调用）。
              .onActionEnd(() => {
                MapController.pinchEnd(this.screenMapWidth, this.mapWidth, this.mapHeight);
              }),
            // 平移手势：单指拖动地图（panOption 的 direction 为 All，上下左右都响应）。
            PanGesture(this.panOption)
              .onActionStart(() => {
                // 清掉上一段手势残留的累计位移，避免第一帧算出巨大的「增量」。
                MapController.panStart();
              })
              .onActionUpdate((event: GestureEvent) => {
                // 控制器只算「相对上一次的增量位移」，并把增量与拖动边界 leftTop 一起回调。
                MapController.panUpdate(event,
                  (mapPanX: number, mapPanY: number, leftTop: Array<number>) => {
                    // 按照位移增量去移动地图。
                    this.mapX += mapPanX;
                    this.mapY += mapPanY;
                    // 限制：四个边界都设一遍，让地图永远不会被拖出可视区域。
                    // leftTop[0] = 屏幕宽度 − 地图宽度（为负），leftTop[1] = 可视区高度 − 地图高度（为负）。
                    if (this.mapX < leftTop[0]) {
                      // 右边界限制：地图右边缘最多贴到屏幕右边缘。
                      this.mapX = leftTop[0];
                    }
                    if (this.mapX > 0) {
                      // 左边界限制。
                      this.mapX = 0;
                    }
                    if (this.mapY > 0) {
                      // 上边界限制。
                      this.mapY = 0;
                    }
                    if (this.mapY < leftTop[1]) {
                      // 下边界限制。
                      this.mapY = leftTop[1];
                    }
                  });
              })
              .onActionEnd(() => {
                // 拖动结束以后，清零 panUpdate 里的累计位移（参考代码同款调用）。
                MapController.panEnd();
              }),
            // 双击：同样放大一档，与捏合共用一个档位计数（到顶后不再放大）。
            TapGesture({ count: Const.MAP_FINGER_COUNT })
              .onAction(() => {
                MapController.tapAction((isMaxTime: boolean) => {
                  if (!isMaxTime) {
                    this.zoomBy(Const.MAP_ZOOM_RATIO);
                  }
                  // 返回放大后的地图左上角允许到达的最远位置，交给控制器当拖动边界。
                  const minX: number = this.screenMapWidth - this.mapWidth;
                  const minY: number = this.mapHeight / MapController.mapMultiples() - this.mapHeight;
                  return [minX, minY];
                });
              })
          )
        )
      }
      .width(Const.FULL_PERCENT)
      .height(Const.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldVal: Area, newVal: Area) => {
        const width = Number(newVal.width);
        const height = Number(newVal.height);
        if (width <= 0 || height <= 0) {
          return;
        }
        const first: boolean = this.screenMapWidth === 0 || this.screenHeight === 0;
        this.screenMapWidth = width;
        this.screenHeight = height;
        this.updateMapSize(first);
        Logger.info(`Map area changed: ${width} x ${height} vp`);
      })

      // 选中站点的浮层卡片：停在面板上方，点一下收起。
      if (this.data.selectedSeq > 0) {
        this.buildSpotCard(this.currentLocation())
      }

      // 底部搜索面板。
      CustomPanel({
        screenMapWidth: $screenMapWidth,
        screenHeight: $screenHeight,
        mapWidth: $mapWidth,
        mapHeight: $mapHeight,
        mapX: $mapX,
        mapY: $mapY,
        onPanelToggle: (collapsed: boolean) => {
          this.onPanelToggle(collapsed);
        }
      })
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
  }

  /**
   * 路线折线：外层暖色光晕 + 内层亮线。
   *
   * 点位已经由控制器换算成当前地图尺寸下的坐标，所以线宽直接用 vp，
   * 屏幕上粗细恒定，不需要再按缩放倍数反算。
   */
  @Builder
  buildRouteLine() {
    Stack({ alignContent: Alignment.TopStart }) {
      Polyline({ width: this.mapWidth, height: this.mapHeight })
        .points(this.routePoints)
        .fillOpacity(0)
        .stroke(Const.ROUTE_GLOW_COLOR)
        .strokeWidth(Const.ROUTE_GLOW_WIDTH)
        .strokeLineCap(LineCapStyle.Round)
        .strokeLineJoin(LineJoinStyle.Round)
      Polyline({ width: this.mapWidth, height: this.mapHeight })
        .points(this.routePoints)
        .fillOpacity(0)
        .stroke(Const.ROUTE_LINE_COLOR)
        .strokeWidth(Const.ROUTE_LINE_WIDTH)
        .strokeLineCap(LineCapStyle.Round)
        .strokeLineJoin(LineJoinStyle.Round)
    }
    .width(this.mapWidth)
    .height(this.mapHeight)
  }

  /**
   * 单个地标：图标（按类型区分）+ 名称。
   *
   * 名称放在图标右侧（MAP_TEXT_OFFSET_X / Y），加一层半透明深色底衬，
   * 保证字压在夜景底图上仍然清晰；选中的站点换成暖黄底衬。
   */
  @Builder
  buildLandmark(item: Location) {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(item.icon)
        .width(Const.MAP_LANDMARKS_SIZE)
        .height(Const.MAP_LANDMARKS_SIZE)
        .draggable(false)
        .interpolation(ImageInterpolation.Medium)
        .onClick(() => {
          this.onLandmarkTap(item);
        })

      Text(item.short)
        .fontSize($r('app.float.map_text_size'))
        .fontWeight(item.selected ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(item.selected ? Const.MAP_BG_COLOR : this.data.textColor)
        .padding({ left: 5, right: 5, top: 1, bottom: 1 })
        .backgroundColor(item.selected ? Const.MARKER_SELECTED_COLOR : Const.MAP_TEXT_BG_COLOR)
        .borderRadius(Const.MAP_TEXT_RADIUS)
        .offset({ x: Const.MAP_TEXT_OFFSET_X, y: Const.MAP_TEXT_OFFSET_Y })
        .onClick(() => {
          this.onLandmarkTap(item);
        })
    }
    .width(Const.MAP_LANDMARKS_SIZE)
    .height(Const.MAP_LANDMARKS_SIZE)
    .offset({ x: item.positionX, y: item.positionY })
  }

  /**
   * 夜爬进度圆点：按当前时刻沿路线移动（未出发 / 已登顶时不显示）。
   */
  @Builder
  buildProgressDot() {
    if (this.climbRate > 0 && this.climbRate < 1) {
      Stack({ alignContent: Alignment.Center }) {
        Circle({ width: Const.PROGRESS_DOT_SIZE * 2.4, height: Const.PROGRESS_DOT_SIZE * 2.4 })
          .fill(Const.PROGRESS_GLOW_COLOR)
        Circle({ width: Const.PROGRESS_DOT_SIZE, height: Const.PROGRESS_DOT_SIZE })
          .fill(Const.PROGRESS_DOT_COLOR)
          .stroke(Const.ROUTE_LINE_COLOR)
          .strokeWidth(2)
      }
      .width(Const.PROGRESS_DOT_SIZE * 2.4)
      .height(Const.PROGRESS_DOT_SIZE * 2.4)
      .offset({
        x: this.progressX - Const.PROGRESS_DOT_SIZE * 1.2,
        y: this.progressY - Const.PROGRESS_DOT_SIZE * 1.2
      })
    }
  }

  /**
   * 地图顶部浮层：标题、夜爬进度、回中按钮。
   */
  @Builder
  buildMapOverlay() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text(Const.MAP_TITLE)
          .fontSize(12)
          .fontColor(Color.White)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(Const.MAP_CHIP_BG)
          .borderRadius(12)
          .hitTestBehavior(HitTestMode.None)
        // 缩放倍数角标：只在放大后出现，自测时一眼能看出现在放大了多少倍
        //（对应「双击 / 捏合到底了没有」）。
        if (this.zoomMultiple > 1) {
          Text(`${this.zoomMultiple.toFixed(2)}×`)
            .fontSize(11)
            .fontColor(Const.ROUTE_LINE_COLOR)
            .padding({ left: 8, right: 8, top: 5, bottom: 5 })
            .backgroundColor(Const.MAP_CHIP_BG)
            .borderRadius(12)
            .hitTestBehavior(HitTestMode.None)
        }
        Blank()
        this.buildRecenterButton()
      }
      .width(Const.FULL_PERCENT)

      Row() {
        Row({ space: 6 }) {
          // 进度小圆点：进行中时用暖黄，未开始 / 已结束用灰色。
          Circle({ width: 7, height: 7 })
            .fill(this.climbRate > 0 && this.climbRate < 1
              ? Const.ROUTE_LINE_COLOR : Const.NIGHT_TEXT_SUB)
          Text(this.progressText)
            .fontSize(11)
            .fontColor(Const.NIGHT_TEXT)
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(Const.MAP_CHIP_BG)
        .borderRadius(12)
        .hitTestBehavior(HitTestMode.None)
        Blank()
      }
      .width(Const.FULL_PERCENT)

      Row() {
        Text(Const.MAP_ZOOM_HINT)
          .fontSize(10)
          .fontColor(Const.NIGHT_TEXT_SUB)
          .hitTestBehavior(HitTestMode.None)
        Blank()
      }
      .width(Const.FULL_PERCENT)
    }
    .width(Const.FULL_PERCENT)
    .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN, top: Const.PAGE_MARGIN })
    // 浮层用 Transparent：空白处的触摸穿透给下面的地图（拖动照常），
    // 内部按钮设回 Default 仍可点击（HitTestMode.None 会连子节点一起屏蔽）。
    .hitTestBehavior(HitTestMode.Transparent)
  }

  /**
   * 回中按钮：白底圆形 + 准星，把地图拉回初始位置。
   */
  @Builder
  buildRecenterButton() {
    Stack({ alignContent: Alignment.Center }) {
      Circle({ width: 40, height: 40 })
        .fill('#FFFFFF')
        .opacity(0.95)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.35)', offsetY: 2 })
      Circle({ width: 16, height: 16 })
        .fill('rgba(0,0,0,0)')
        .stroke('#555555')
        .strokeWidth(2)
      Circle({ width: 4, height: 4 })
        .fill(Const.MAP_PIN_COLOR)
    }
    .hitTestBehavior(HitTestMode.Default)
    .onClick(() => {
      // 顺手把缩放一起复位：放大状态下点「回中」，得到的应该是初始视野，
      // 而不是「放大后的地图中心」。
      this.resetView();
    })
  }

  /**
   * 选中站点的浮层卡片：实景照片 + 站点信息 + 一句话夜爬提示，
   * 停在面板上方（面板收起 / 展开时跟着上下移动），点一下收起。
   */
  @Builder
  buildSpotCard(location: Location) {
    Column() {
      Row({ space: 10 }) {
        Image(location.photo)
          .width(Const.SPOT_THUMB_WIDTH)
          .height(Const.SPOT_THUMB_HEIGHT)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .draggable(false)
          .interpolation(ImageInterpolation.Medium)

        Column({ space: 4 }) {
          Row({ space: 6 }) {
            Text(location.name)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A2434')
            Text(stationKindName(location.kind))
              .fontSize(10)
              .fontColor(Const.MAP_BG_COLOR)
              .backgroundColor(Const.MARKER_SELECTED_COLOR)
              .padding({ left: 6, right: 6, top: 1, bottom: 1 })
              .borderRadius(7)
          }
          .width(Const.FULL_PERCENT)

          Text(`海拔 ${location.altitude} m · 累计 ${location.distance} km · 建议 ${location.time} 到达`)
            .fontSize(11)
            .fontColor('#5B6879')

          Text(location.tip)
            .fontSize(11)
            .fontColor('#8A96A6')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(Const.FULL_PERCENT)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width(Const.FULL_PERCENT)
      .padding(8)
      .backgroundColor('#F2F5FA')
      .borderRadius(12)
      .onClick(() => {
        this.data = MapController.selectLandmark(this.data, 0);
      })
    }
    .width(Const.FULL_PERCENT)
    .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN })
    .margin({
      bottom: (this.panelCollapsed ? Const.PANEL_ARROW_HEIGHT : Const.PANEL_TOTAL_HEIGHT)
        + Const.SPOT_CARD_GAP
    })
  }
}

/**
 * 底部搜索面板（参考代码的 CustomPanel）。
 *
 * 「展开 / 收起」靠三个状态一起变：内容区高度、内容区透明度、箭头透明度
 * （收起时箭头仍然留在屏幕底部，用来把面板重新拉起来）。
 * 面板不直接改地图，而是通过 @Link 与地图共享 mapX / mapY、mapWidth / mapHeight，
 * 搜索或点宫格时调用 setFirstLandmarkscenter() 把目标站点挪到屏幕中央。
 */
@Component
struct CustomPanel {
  /**
   * 面板宫格的地标列表（从站点数据源派生）。
   */
  @State positionList: Array<PositionItem> = PositionList;
  /**
   * 面板内容区透明度：展开 0.8，收起 0。
   */
  @State panelOpacity: number = Const.PANEL_HIGH_OPACITY;
  /**
   * 面板内容区高度：展开 PANEL_FULL_HEIGHT，收起 0。
   */
  @State panelHeight: number = Const.PANEL_FULL_HEIGHT;
  /**
   * 折叠箭头当前是否朝下（朝下 = 面板展开中），以及箭头透明度。
   */
  @State isDownImage: boolean = true;
  @State iconOpacity: number = Const.PANEL_HIGH_OPACITY;
  /**
   * 动画过程中临时屏蔽点击，避免连续点导致状态错乱。
   */
  @State imageEnable: boolean = true;
  /**
   * 与地图双向绑定的视口 / 地图尺寸与偏移。
   */
  @Link screenMapWidth: number;
  @Link screenHeight: number;
  @Link mapWidth: number;
  @Link mapHeight: number;
  @Link mapX: number;
  @Link mapY: number;
  /**
   * 地图共享过来的地标数据（含当前选中站点）。
   */
  @Consume data: AddressItem;
  /**
   * 面板折叠 / 展开时通知地图重算地图层尺寸。
   */
  onPanelToggle: (collapsed: boolean) => void = () => {
  };

  /**
   * 展开 / 收起面板：同时改内容区高度、透明度与箭头透明度。
   */
  private upAndDown(): void {
    this.imageEnable = false;
    if (this.isDownImage) {
      this.panelOpacity = 0;
      this.panelHeight = 0;
      this.iconOpacity = Const.PANEL_LOW_OPACITY;
    } else {
      this.panelHeight = Const.PANEL_FULL_HEIGHT;
      this.panelOpacity = Const.PANEL_HIGH_OPACITY;
      this.iconOpacity = Const.PANEL_HIGH_OPACITY;
    }
    this.isDownImage = !this.isDownImage;
    this.imageEnable = true;
    this.onPanelToggle(!this.isDownImage);
  }

  /**
   * 地标定位后，把该地标挪到屏幕中央（参考代码同名方法）。
   */
  private setFirstLandmarkscenter(): void {
    const location: Location | null = MapController.selectedLocation(this.data);
    if (location === null) {
      return;
    }
    const offset: Array<number> = MapController.centerOffset(location);
    this.mapX = offset[0];
    this.mapY = offset[1];
  }

  /**
   * 点宫格里的站点：换算出它在屏幕上的位置，选中并把地图挪过去。
   *
   * 这里不收起面板（参考代码会顺手 upAndDown），否则选中站点的详情卡片
   * 会跟着面板一起被收起来，看不到内容。
   */
  private onPositionTap(item: PositionItem): void {
    this.data = MapController.calCoordinateByLonAndLat(
      item.position, item.kind, this.mapWidth, this.mapHeight);
    this.setFirstLandmarkscenter();
    Logger.info(`Map locate station: ${item.text}`);
  }

  /**
   * 宫格项的 ForEach 键值：把选中状态编进键值，切换站点时高亮才会刷新
   * （原因同 Map.landmarkKey）。
   */
  private gridKey(item: PositionItem): string {
    return `position${item.seq}_${this.data.selectedSeq === item.seq ? 1 : 0}`;
  }

  /**
   * 在宫格列表里找匹配的站点下标：先按全等（含序号）找，再退化成包含匹配。
   */
  private matchPositionIndex(query: string): number {
    for (let i = 0; i < this.positionList.length; i++) {
      const text: string = MapController.getResourceString(this.positionList[i].text);
      if (text === query || `${this.positionList[i].seq}` === query) {
        return i;
      }
    }
    for (let i = 0; i < this.positionList.length; i++) {
      const text: string = MapController.getResourceString(this.positionList[i].text);
      if (text.indexOf(query) >= 0) {
        return i;
      }
    }
    return -1;
  }

  /**
   * 搜索框回车：找到匹配的站点并定位（参考代码是用 forEach 逐个比对）。
   */
  private onSearchSubmit(value: string): void {
    const query: string = MapController.getResourceString(value);
    if (query.length === 0) {
      return;
    }
    const index: number = this.matchPositionIndex(query);
    if (index >= 0) {
      this.onPositionTap(this.positionList[index]);
    } else {
      Logger.info(`Map search no match: ${query}`);
    }
  }

  build() {
    Column() {
      // 展开和缩起图标
      Column() {
        Image(this.isDownImage ? $r('app.media.ic_panel_down') : $r('app.media.ic_panel_up'))
          .height($r('app.float.navigation_icon_down'))
          .enabled(this.imageEnable)
          .onClick(() => {
            this.upAndDown();
          })
      }
      .opacity(this.iconOpacity)
      .backgroundColor($r('app.color.custom_panel_background'))
      .borderRadius({
        topLeft: $r('app.float.navigation_panel_radius'),
        topRight: $r('app.float.navigation_panel_radius')
      })
      .width(Const.FULL_PERCENT)

      // 搜索模块具体内容
      Column() {
        Search({ placeholder: Const.PANEL_PLACEHOLDER })
          .height($r('app.float.navigation_search_height'))
          .width(Const.SEARCHBAR_WIDTH)
          .backgroundColor(Const.PANEL_SEARCH_BG)
          .margin({ top: 8 })
          .onSubmit((value: string) => {
            this.onSearchSubmit(value);
          })

        Grid() {
          ForEach(this.positionList, (item: PositionItem) => {
            GridItem() {
              PositionGrid({
                positionItem: item,
                selected: this.data.selectedSeq === item.seq
              })
            }
            .enabled(this.imageEnable)
            .onClick(() => {
              // 点击搜索图标，进行回调
              this.onPositionTap(item);
            })
          }, (item: PositionItem) => this.gridKey(item))
        }
        .columnsTemplate(Const.GRID_COLUMNS)
        .rowsTemplate(Const.GRID_ROWS)
        .columnsGap($r('app.float.navigation_column_gap'))
        .rowsGap($r('app.float.navigation_row_gap'))
        .padding($r('app.float.navigation_grid_padding'))
        .height(Const.GRID_HEIGHT)
      }
      .opacity(this.panelOpacity)
      .height(this.panelHeight)
      .animation({
        duration: Const.ANIMATION_DURATION,
        curve: Curve.EaseOut,
        iterations: 1,
        playMode: PlayMode.Normal
      })
      .backgroundColor($r('app.color.custom_panel_background'))
    }
    .width(Const.FULL_PERCENT)
    .borderRadius($r('app.float.navigation_panel_radius'))
  }
}

/**
 * 面板宫格里的单个站点：图标在上、名称在下。
 */
@Component
struct PositionGrid {
  /**
   * 该格对应的地标项。
   */
  positionItem: PositionItem = new PositionItem();
  /**
   * 是否为当前选中的站点（选中时名称高亮）。
   */
  selected: boolean = false;

  build() {
    Column() {
      Image(this.positionItem.icon)
        .width($r('app.float.navigation_panel_icon_size'))
        .height($r('app.float.navigation_panel_icon_size'))
        .margin($r('app.float.navigation_panel_icon_margin'))
        .draggable(false)
      Text(this.positionItem.text)
        .fontSize($r('app.float.navigation_icon_text'))
        .fontColor(this.selected ? Const.PANEL_ITEM_TEXT_ACTIVE : Const.PANEL_ITEM_TEXT)
        .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Normal)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(Const.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }
}
