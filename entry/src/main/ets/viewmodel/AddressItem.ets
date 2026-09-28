/**
 * 地图地标数据模型（Tab1 路线图）。
 *
 * 结构沿用参考写法：AddressItem 里装一个 Location 数组，再带上这一组地标
 * 通用的图标 / 名称 / 文字颜色。
 *
 * 与参考代码的差别只有一处：参考里地标图标与名称取自 this.data.icon /
 * this.data.name（一组地标共用一个图标、一个名字），而本工程 15 个站点各有
 * 各的名称、图标与照片，所以图标与名称挂在 Location 上；AddressItem 上的
 * 这两个字段用来承载「当前选中的站点」。
 */
import { StationKind } from './MapModel';

/**
 * 地图上的一个地标点。
 */
export class Location {
  /**
   * 站点序号（1 起，与夜爬先后顺序一致）。
   */
  seq: number = 0;
  /**
   * 站点全名。
   */
  name: string = '';
  /**
   * 地图标记与面板宫格上显示的短名（2~4 字）。
   */
  short: string = '';
  /**
   * 站点类型，决定图标与配色。
   */
  kind: StationKind = StationKind.PASS;
  /**
   * 海拔（米）。
   */
  altitude: number = 0;
  /**
   * 距起点累计里程（公里）。
   */
  distance: number = 0;
  /**
   * 建议到达时刻（HH:MM）。
   */
  time: string = '';
  /**
   * 一句话夜爬提示。
   */
  tip: string = '';
  /**
   * 导览页简介。
   */
  intro: string = '';
  /**
   * 站点实景照片。
   */
  photo: Resource = $r('app.media.hs_spot_01');
  /**
   * 站点图标（按类型区分形状与颜色）。
   */
  icon: Resource = $r('app.media.ic_hs_mark_pass');
  /**
   * 是否为关键站点（起点 / 险段 / 主峰 / 关隘）。
   */
  key: boolean = false;
  /**
   * 在底图上的标定坐标（原始像素），是坐标换算的基准。
   */
  baseX: number = 0;
  baseY: number = 0;
  /**
   * 当前地图尺寸下、地标图标左上角的坐标（由 MapController 换算）。
   */
  positionX: number = 0;
  positionY: number = 0;
  /**
   * 是否为当前选中的站点。
   */
  selected: boolean = false;
}

/**
 * 一组地标 + 这一组地标的样式。
 */
export class AddressItem {
  /**
   * 地标集合。
   */
  location: Array<Location> = [];
  /**
   * 地标图标（这里承载「当前选中站点」的图标）。
   */
  icon: Resource = $r('app.media.ic_hs_mark_start');
  /**
   * 地标名称（这里承载「当前选中站点」的名称）。
   */
  name: string = '';
  /**
   * 地图上的文字颜色。
   */
  textColor: string = '#FFFFFF';
  /**
   * 当前选中的站点序号，0 表示没有选中任何站点。
   */
  selectedSeq: number = 0;
}
