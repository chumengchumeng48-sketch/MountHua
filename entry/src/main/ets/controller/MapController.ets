/**
 * 地图页控制器（结构沿用参考写法）。
 *
 * 只做「算」的活：坐标换算、边界钳制、选中态组装、路线点位换算，
 * 自身不持有任何界面状态 —— 页面里只管把算出来的结果塞进 @State / @Provide。
 */
import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import { AddressItem, Location } from '../viewmodel/AddressItem';
import {
  IStation,
  StationKind,
  routePath,
  stations,
  stationMarkIcon
} from '../viewmodel/MapModel';

export class MapController {
  /**
   * 地图视口宽度（屏幕宽度）。
   */
  private static screenMapWidth: number = 0;
  /**
   * 地图视口高度（已经扣掉面板占用的高度）。
   */
  private static screenHeight: number = 0;
  /**
   * 当前地图层尺寸。
   */
  private static mapWidth: number = 0;
  private static mapHeight: number = 0;
  /**
   * 地图左上角允许到达的最远位置 [minX, minY]（参考代码的 leftTop）。
   *
   * 两个分量都 ≤ 0：地图层往左上拖到「右下角贴住可视区右下角」就到头了。
   * 由 initLeftTop / pinchEnd 刷新，clampMapX / clampMapY 按它钳制 ——
   * 拖动边界与缩放边界是同一个来源，不会各算一套。
   */
  private static leftTop: Array<number> = [0, 0];

  /**
   * 初始化组件：计算地图左上角允许到达的最远位置（参考代码同名方法）。
   *
   * 比参考代码多收一个 screenHeight —— 它是纵向边界与缩放倍率的基准，
   * 少了它放大后就判断不出「有没有拖出留白」。
   */
  static initLeftTop(screenMapWidth: number, screenHeight: number,
    mapWidth: number, mapHeight: number): void {
    MapController.screenMapWidth = screenMapWidth;
    MapController.screenHeight = screenHeight;
    MapController.mapWidth = mapWidth;
    MapController.mapHeight = mapHeight;
    MapController.leftTop = [
      screenMapWidth - mapWidth,
      screenHeight - mapHeight
    ];
  }

  /**
   * 取字符串文案。
   *
   * 参考代码里 PositionItem.text 是 $r('app.string.xxx')，需要先把 Resource
   * 解析成字符串再和搜索框里的输入比较；本工程的站点名本身就是普通字符串，
   * 这里统一做一次去首尾空格，保持调用点与参考代码一致。
   */
  static getResourceString(value: string): string {
    return value === undefined || value === null ? '' : value.trim();
  }

  /**
   * 从站点数据源生成地图要渲染的地标集合。
   */
  static buildAddressItem(): AddressItem {
    const data = new AddressItem();
    const list: Array<Location> = [];
    stations.forEach((station: IStation) => {
      const item = new Location();
      item.seq = station.seq;
      item.name = station.name;
      item.short = station.short;
      item.kind = station.kind;
      item.altitude = station.altitude;
      item.distance = station.distance;
      item.time = station.time;
      item.tip = station.tip;
      item.intro = station.intro;
      item.photo = station.photo;
      item.icon = stationMarkIcon(station.kind);
      item.key = station.key;
      item.baseX = station.pinX;
      item.baseY = station.pinY;
      list.push(item);
    });
    data.location = list;
    data.textColor = Const.MAP_TEXT_COLOR;
    return MapController.calLandmarksPosition(data);
  }

  /**
   * 地标坐标换算：底图标定坐标 → 当前地图尺寸下的坐标。
   *
   * 参考代码这里是从经纬度按底图的经纬度范围反算像素；本工程的底图是手绘
   * 插画（不是地理投影图），经纬度反算没有意义，所以换算基准换成
   * 「底图像素 → 地图显示像素」，换算公式与调用形态保持一致。
   *
   * 换算结果是「地标图标左上角」的坐标，与参考代码里 offset 直接用
   * positionX / positionY 的写法一致。
   */
  static calLandmarksPosition(data: AddressItem): AddressItem {
    if (MapController.mapWidth <= 0 || MapController.mapHeight <= 0) {
      return data;
    }
    const scaleX = MapController.mapWidth / Const.MAP_WIDTH;
    const scaleY = MapController.mapHeight / Const.MAP_HEIGHT;
    data.location.forEach((item: Location) => {
      item.positionX = item.baseX * scaleX;
      item.positionY = item.baseY * scaleY;
    });
    return data;
  }

  /**
   * 地标坐标 → 当前地图尺寸下的像素坐标，并组装成可渲染的 AddressItem。
   *
   * 参数形态与参考代码一致（position 相当于参考里的 lngLat，kind 相当于 type），
   * 内部按坐标匹配到具体站点后，顺手把它标成选中态。
   */
  static calCoordinateByLonAndLat(position: Array<number>, kind: StationKind,
    mapWidth: number, mapHeight: number): AddressItem {
    MapController.initLeftTop(MapController.screenMapWidth, MapController.screenHeight,
      mapWidth, mapHeight);
    let data: AddressItem = MapController.buildAddressItem();
    for (let i = 0; i < data.location.length; i++) {
      const item: Location = data.location[i];
      if (item.baseX === position[0] && item.baseY === position[1] && item.kind === kind) {
        data = MapController.selectLandmark(data, item.seq);
        break;
      }
    }
    return data;
  }

  /**
   * 切换选中站点。
   *
   * 这里整体重建一个 AddressItem 再赋值，和参考代码里
   * 「this.data = MapModel.calCoordinateByLonAndLat(...)」的写法一致 ——
   * ArkUI 只有整体重新赋值才会触发子组件刷新。
   */
  static selectLandmark(data: AddressItem, seq: number): AddressItem {
    const next: AddressItem = MapController.buildAddressItem();
    next.selectedSeq = seq;
    next.location.forEach((item: Location) => {
      if (item.seq === seq) {
        item.selected = true;
        next.name = item.name;
        next.icon = item.icon;
      }
    });
    return next;
  }

  /**
   * 取当前选中的地标，没有选中时返回 null。
   */
  static selectedLocation(data: AddressItem): Location | null {
    for (let i = 0; i < data.location.length; i++) {
      if (data.location[i].seq === data.selectedSeq) {
        return data.location[i];
      }
    }
    return null;
  }

  /**
   * 把某个地标挪到屏幕中央：返回地图层应该用的 [mapX, mapY]，已按边界钳制。
   */
  static centerOffset(location: Location): Array<number> {
    const half: number = Const.MAP_LANDMARKS_SIZE / Const.DOUBLE_OR_HALF;
    const x: number = MapController.screenMapWidth / Const.DOUBLE_OR_HALF
      - location.positionX - half;
    const y: number = MapController.screenHeight / Const.DOUBLE_OR_HALF
      - location.positionY - half;
    return [MapController.clampMapX(x), MapController.clampMapY(y)];
  }

  /**
   * 路线折线换算：底图标定坐标 → 当前地图尺寸下的坐标。
   */
  static calRoutePath(): Array<Array<number>> {
    const path: Array<Array<number>> = [];
    if (MapController.mapWidth <= 0 || MapController.mapHeight <= 0) {
      return path;
    }
    const scaleX: number = MapController.mapWidth / Const.MAP_WIDTH;
    const scaleY: number = MapController.mapHeight / Const.MAP_HEIGHT;
    routePath.forEach((point: Array<number>) => {
      path.push([point[0] * scaleX, point[1] * scaleY]);
    });
    return path;
  }

  /**
   * 单个点位换算（夜爬进度点用）。
   */
  static calPoint(point: Array<number>): Array<number> {
    if (MapController.mapWidth <= 0 || MapController.mapHeight <= 0) {
      return [0, 0];
    }
    return [
      point[0] * MapController.mapWidth / Const.MAP_WIDTH,
      point[1] * MapController.mapHeight / Const.MAP_HEIGHT
    ];
  }

  /**
   * ===== 平移（单指拖动）=====
   */
  /**
   * 上一次回调时的累计位移（对应 event.offsetX / offsetY）。
   *
   * event.offsetX 给的是「本次手势内的累计位移」，而地图要的是「相对上一次的增量」，
   * 靠这两个字段做差分；由 panStart / panEnd 清零。
   */
  private static panX: number = 0;
  private static panY: number = 0;

  /**
   * 拖动手势开始：清掉上一段的累计位移。
   *
   * 参考代码只在 panEnd 里清零。这里在开始处也清一次 —— 手势被系统打断
   * （切后台、被同组手势抢走）时 onActionEnd 不一定触发，残留的累计位移
   * 会让下一段拖动的第一帧算出一个巨大的「增量」，地图会瞬移一下。
   */
  static panStart(): void {
    MapController.panX = 0;
    MapController.panY = 0;
  }

  /**
   * 平移（单指拖动地图，参考代码同名方法）。
   *
   * event.offsetX / offsetY 是本次手势的**累计**位移，这里差分出增量，
   * 再把增量与拖动边界 leftTop 一起回调给页面 —— 页面按增量移动地图、
   * 按 leftTop 做四个方向的边界限制（与参考代码的分工一致）。
   *
   * toFixed(0) 取整是为了消掉亚像素抖动：不取整的话每帧浮点尾数都不同，
   * 会白白触发一次次回调与重算。
   */
  static panUpdate(event: GestureEvent,
    callBack: (mapPanX: number, mapPanY: number, leftTop: Array<number>) => void): void {
    const panX: number = Number.parseInt(event.offsetX.toFixed(0));
    const panY: number = Number.parseInt(event.offsetY.toFixed(0));
    // 只有累计位移真的变了才处理，避免同一位置重复触发回调。
    if (MapController.panX !== panX || MapController.panY !== panY) {
      // 本次的增量位移 = 当前累计位移 − 上一个节点累计的位移。
      const mapPanX: number = panX - MapController.panX;
      const mapPanY: number = panY - MapController.panY;
      callBack(mapPanX, mapPanY, MapController.leftTop);
    }
    MapController.panX = panX;
    MapController.panY = panY;
  }

  /**
   * 平移结束：清零累计位移（参考代码同款）。
   */
  static panEnd(): void {
    MapController.panX = 0;
    MapController.panY = 0;
  }

  /**
   * ===== 缩放（双指捏合）=====
   */
  /**
   * 上一次回调时的累计缩放倍数（event.scale；每次手势都从 1 重新计数，手势开始置 0）。
   */
  private static previousScale: number = 0;
  /**
   * 已经放大的档数（0 ~ ZOOM_MAX_TIMES），跨手势保留 —— 它就是当前的缩放档位。
   */
  private static pinchCount: number = 0;
  /**
   * 本次捏合手势开始时的档位。
   *
   * event.scale 只反映「本次手势」的倍数，档位必须以此手势开始时的档数为基准累加，
   * 否则每次重新捏合都会从 0 档重来（一松手再捏就弹回原大小）。
   */
  private static pinchBaseCount: number = 0;

  /**
   * 捏合手势开始（对应 PinchGesture.onActionStart）。
   */
  static pinchStart(): void {
    MapController.pinchBaseCount = MapController.pinchCount;
    MapController.previousScale = 0;
  }

  /**
   * 双指捏合：把累计倍数换算成缩放档位，每跨过一档回调一次倍率。
   *
   * 与参考代码的差异（参考代码是按「每个事件固定乘一次 MAP_ZOOM_RATIO」做的）：
   * 它用 event.scale.toFixed(2) 判断「倍数有没有变化」，而一个手势内这类事件非常密集，
   * 4 档上限往往第一次捏合就撑满（之后无论怎么捏都不动），一捏就是「直接顶到最大」。
   * 这里改成按累计倍数换算档位：round(log(scale) / log(MAP_ZOOM_RATIO))，
   * 手势内每跨过一档才回调一次；倍率仍然是 MAP_ZOOM_RATIO 的整数次幂，
   * pinchCount 的 0 ~ ZOOM_MAX_TIMES 上限含义与参考代码完全一致。
   *
   * 回调类型写成 (ratio: number) => void 而不是参考代码的 Function：
   * ArkTS 对 Function 类型的调用有额外限制，写成明确签名更稳。
   */
  static pinchUpdate(event: GestureEvent, callBack: (ratio: number) => void): void {
    const scale: number = Number.parseFloat(event.scale.toFixed(Const.MAP_SCALE_ACCURACY));
    if (scale <= 0 || MapController.previousScale === scale) {
      return;
    }
    MapController.previousScale = scale;
    // 本次手势的倍数换算成「跨过了几档」
    const level: number = Math.round(Math.log(scale) / Math.log(Const.MAP_ZOOM_RATIO));
    let target: number = MapController.pinchBaseCount + level;
    if (target > Const.ZOOM_MAX_TIMES) {
      target = Const.ZOOM_MAX_TIMES; // 防止无限放大
    }
    if (target < 0) {
      target = 0; // 防止无限缩小（最小就是铺满可视区）
    }
    const step: number = target - MapController.pinchCount;
    if (step === 0) {
      return; // 已经顶到上限 / 下限，不再回调
    }
    MapController.pinchCount = target;
    callBack(Math.pow(Const.MAP_ZOOM_RATIO, step));
  }

  /**
   * 捏合 / 放开结束后，重新计算地图左上角允许到达的最远位置（参考代码的 pinchEnd）。
   *
   * x 轴：地图右边最多贴到屏幕的右边 → minX = screenMapWidth - mapWidth。
   * y 轴：地图下边最多贴到可视区的下边缘 → minY = screenHeight - mapHeight。
   *
   * 参考代码 y 轴写的是 (1 / (mapMultiples() - 1)) * mapHeight —— 1 倍时除以 0，
   * 且量纲对不上；这里按它自己注释里的「地图高度 / 地图比例 - 地图高度」来写：
   * mapHeight / mapMultiples() 就是可视区高度，两者等价，但 1 倍时得到 0 而非 Infinity。
   */
  static pinchEnd(screenMapWidth: number, mapWidth: number, mapHeight: number): void {
    MapController.screenMapWidth = screenMapWidth;
    MapController.mapWidth = mapWidth;
    MapController.mapHeight = mapHeight;
    MapController.leftTop = [
      screenMapWidth - mapWidth,
      MapController.screenHeight - mapHeight
    ];
  }

  /**
   * 双击：把地图放大一档，与捏合共用一个档位计数（参考代码的 tapAction）。
   *
   * callBack 在组件里完成这次缩放与地标重排，并把「放大后左上角允许到达的最远位置」
   * 返回给控制器 —— 直接拿它当拖动边界（this.leftTop）。
   * 已经到 ZOOM_MAX_TIMES 档时 isMaxTime 为 true，调用方跳过缩放、直接返回边界即可。
   */
  static tapAction(callBack: (isMaxTime: boolean) => Array<number>): void {
    let isMaxTime: boolean = false;
    MapController.pinchCount++;
    if (MapController.pinchCount > Const.ZOOM_MAX_TIMES) {
      MapController.pinchCount = Const.ZOOM_MAX_TIMES; // 防止无限增大
      isMaxTime = true;
    }
    MapController.leftTop = callBack(isMaxTime);
  }

  /**
   * 直接跳到指定档位，返回相对当前的倍率（「回中」复位用）；
   * 已经在目标档位时返回 1（调用方据此跳过重算）。
   */
  static zoomToTimes(times: number): number {
    let target: number = times;
    if (target > Const.ZOOM_MAX_TIMES) {
      target = Const.ZOOM_MAX_TIMES;
    }
    if (target < 0) {
      target = 0;
    }
    const step: number = target - MapController.pinchCount;
    MapController.pinchCount = target;
    MapController.pinchBaseCount = target;
    MapController.previousScale = 0;
    return step === 0 ? 1 : Math.pow(Const.MAP_ZOOM_RATIO, step);
  }

  /**
   * 当前缩放倍数 = 当前地图层高度 / 未缩放时铺满可视区的高度。
   */
  static mapMultiples(): number {
    if (MapController.screenHeight <= 0) {
      return 1;
    }
    return MapController.mapHeight / MapController.screenHeight;
  }

  /**
   * 横向边界钳制：地图比视口宽时可以左右拖动，但不允许拖出留白；
   * 比视口窄时整体居中（与参考代码的 mapX 算法一致）。
   * 边界取 leftTop[0]（= screenMapWidth - mapWidth），由 initLeftTop / pinchEnd 刷新。
   */
  static clampMapX(x: number): number {
    if (MapController.mapWidth <= MapController.screenMapWidth) {
      return (MapController.screenMapWidth - MapController.mapWidth) / Const.DOUBLE_OR_HALF;
    }
    return Math.min(0, Math.max(x, MapController.leftTop[0]));
  }

  /**
   * 纵向边界钳制：地图顶部不允许低于视口顶部，留白只留在下方（面板那一侧）。
   * 边界取 leftTop[1]（可视区高度 − mapHeight，可视区高度不含底部面板）。
   */
  static clampMapY(y: number): number {
    if (MapController.mapHeight <= MapController.screenHeight) {
      return 0;
    }
    return Math.min(0, Math.max(y, MapController.leftTop[1]));
  }
}
