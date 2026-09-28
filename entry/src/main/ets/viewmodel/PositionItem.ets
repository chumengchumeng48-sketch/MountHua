/**
 * 搜索面板宫格里的一个地标项（结构沿用参考写法）。
 *
 * icon / text 是宫格要显示的内容；position 是这个地标在底图上的标定坐标，
 * kind 是站点类型、seq 是站点序号 —— 搜索或点击宫格时，用它们去换算屏幕
 * 坐标、把地图定位到该站点。
 *
 * 站点数据不在本文件里另写一份，统一从 viewmodel/MapModel.stations 派生，
 * 保证「路线图 / 沿途站点 / 夜爬时刻」三处永远用的是同一份数据。
 */
import {
  IStation,
  StationKind,
  stations,
  stationKindColor,
  stationMarkIcon
} from './MapModel';

/**
 * 面板宫格项。
 */
export class PositionItem {
  /**
   * 宫格图标。
   */
  icon: Resource = $r('app.media.ic_hs_mark_pass');
  /**
   * 宫格文字（站点短名）。
   */
  text: string = '';
  /**
   * 底图上的标定坐标 [x, y]。
   */
  position: Array<number> = [];
  /**
   * 站点类型。
   */
  kind: StationKind = StationKind.PASS;
  /**
   * 站点序号。
   */
  seq: number = 0;
  /**
   * 站点主色，用于宫格文字的选中高亮。
   */
  color: string = '#FFFFFF';
}

/**
 * 从站点数据源派生面板宫格列表。
 */
function buildPositionList(): Array<PositionItem> {
  const list: Array<PositionItem> = [];
  stations.forEach((station: IStation) => {
    const item = new PositionItem();
    item.icon = stationMarkIcon(station.kind);
    item.text = station.short;
    item.position = [station.pinX, station.pinY];
    item.kind = station.kind;
    item.seq = station.seq;
    item.color = stationKindColor(station.kind);
    list.push(item);
  });
  return list;
}

/**
 * 面板宫格的地标列表（15 个夜爬站点）。
 */
export const PositionList: Array<PositionItem> = buildPositionList();
