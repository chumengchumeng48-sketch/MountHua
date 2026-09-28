/**
 * 沿途站点显示模型类（对应老师参考工程的 ZonesViewModel）。
 *
 * 职责与参考工程一致：
 *   1. getZonesList()  返回全部站点列表，供 ZonesView 组件 ForEach 渲染卡片；
 *   2. getZonesByIndex(index) 按下标取单个站点，供「按当前进度定位站内位置」
 *      与后续的站点详情取数；
 *   3. getZoneById(id) 按站点序号取站点，供详情页解析路由传参；
 *   4. 单例导出：整个应用共享同一份显示模型，避免重复实例化、重复装配。
 *
 * 与参考工程的差别只有一处：参考工程的 12 个区域数据是直接写在
 * 本文件的 defaultList 里（文字 / 颜色硬编码）；本项目则按工程约定
 * 「站点数据只保留 MapModel.stations 一份」，本文件只做**装配**——
 * 把 IStation 换算成页面直接可读的 ZonesItem（类型名、类型配色、图标、
 * 相对爬升、时间轴进度、海拔里程文案、详情页的邻站影像），不另存一份站点数据。
 *
 * @version 1.1
 */
import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import ZonesItem from './ZonesItem';
import {
  IStation,
  stations,
  routeSummary,
  climbProgress,
  stationKindColor,
  stationKindName,
  stationMarkIcon,
  stationProgress
} from './MapModel';

/**
 * 全程总览（Tab2 顶部总览卡用）。
 */
export class ZonesSummary {
  /**
   * 站点数。
   */
  count: number = 0;
  /**
   * 全程里程（公里）。
   */
  distance: number = 0;
  /**
   * 累计爬升（米）。
   */
  ascent: number = 0;
  /**
   * 预计用时（分钟）。
   */
  durationMinutes: number = 0;
  /**
   * 预计用时文案（形如「7 时 50 分」）。
   */
  durationText: string = '';
  /**
   * 出发时刻（HH:MM）。
   */
  startTime: string = '';
  /**
   * 登顶时刻（HH:MM）。
   */
  summitTime: string = '';
}

class ZonesViewModel {
  /**
   * 全程总览：构造时装配一次，页面直接读字段，不在 build() 里重复创建对象。
   */
  readonly summary: ZonesSummary = buildSummary();

  /**
   * 返回全部站点列表（供 ZonesView 组件 ForEach 渲染卡片）。
   */
  getZonesList(): ZonesItem[] {
    return defaultList;
  }

  /**
   * 按下标取单个站点（供按当前进度定位 / 站点详情取数）。
   *
   * 参考工程是直接返回 defaultList[index]；这里加了下标收敛，
   * 免得调用方算出越界下标后拿到 undefined。
   */
  getZonesByIndex(index: number): ZonesItem {
    if (index <= 0) {
      return defaultList[0];
    }
    if (index >= defaultList.length) {
      return defaultList[defaultList.length - 1];
    }
    return defaultList[index];
  }

  /**
   * 按站点序号取站点（详情页解析路由传参用）。
   *
   * 传过来的是页面外的数据，可能是越界值甚至 NaN，所以找不到就回落到第一站：
   * 详情页宁可显示玉泉院，也不能白屏。
   */
  getZoneById(id: number): ZonesItem {
    for (let i = 0; i < defaultList.length; i++) {
      if (defaultList[i].id === id) {
        return defaultList[i];
      }
    }
    return defaultList[0];
  }

  /**
   * 当前时刻对应的夜爬进度（0 ~ 1）。
   */
  getClimbRate(now: Date): number {
    return climbProgress(now);
  }

  /**
   * 当前进度所在的站点下标（0 起）。
   */
  getCurrentIndex(progress: number): number {
    let index: number = 0;
    for (let i = 0; i < defaultList.length; i++) {
      if (progress >= defaultList[i].progress) {
        index = i;
      }
    }
    return index;
  }

  /**
   * 当前进度所在的站点（卡片「当前位置」高亮与总览卡「已过 xx」文案用）。
   */
  getCurrentZone(progress: number): ZonesItem {
    return this.getZonesByIndex(this.getCurrentIndex(progress));
  }
}

/**
 * 15 个夜爬站点的装配结果（构造一次，全局共享）。
 */
const defaultList: ZonesItem[] = buildZonesList();

/**
 * 单例导出：整个应用共享同一份显示模型，避免重复实例化。
 */
let zonesViewModel = new ZonesViewModel();

export default zonesViewModel as ZonesViewModel;

/**
 * 把站点数据源装配成页面直接可读的显示模型列表。
 */
function buildZonesList(): ZonesItem[] {
  const list: ZonesItem[] = [];
  stations.forEach((station: IStation, index: number) => {
    list.push(buildZonesItem(station, index));
  });
  return list;
}

/**
 * 装配单个站点：所有「算出来」的字段都在这里定稿，页面只读不算。
 *
 * @param station 站点数据源里的一条
 * @param index   在数据源里的下标（用来取上一站算爬升、取邻站拼影像）
 */
function buildZonesItem(station: IStation, index: number): ZonesItem {
  const item = new ZonesItem();
  item.id = station.seq;
  item.title = station.name;
  item.subTitle = stationKindName(station.kind);
  item.shortTitle = station.short;
  item.kind = station.kind;
  item.backgroundColor = stationKindColor(station.kind);
  item.titleIcon = stationMarkIcon(station.kind);
  item.arriveTime = station.time;
  item.altitude = station.altitude;
  item.distance = station.distance;
  // 相对上一站的爬升：首站没有上一站，记 0（这段算法原来写在页面里，现收进数据层）。
  item.ascent = index > 0 ? station.altitude - stations[index - 1].altitude : 0;
  item.metaText = `海拔 ${station.altitude} m · 累计 ${station.distance} km · 距上一点 +${item.ascent} m`;
  item.progress = stationProgress(station);
  item.key = station.key;
  item.photo = station.photo;
  item.tip = station.tip;
  item.intro = station.intro;
  fillNeighborPhotos(item, index);
  return item;
}

/**
 * 装配详情页「沿途影像」卡组：以本站为中心，向前后各取若干站，拼成一条
 * 按夜爬顺序排列的照片列表。
 *
 * 首尾按环上顺序回绕（第 1 站的前一站是最后一站），所以从任何一站进来
 * 都能滑到「前后都有的」影像；回绕用的是取余，负偏移先补一圈再取余，
 * 避免出现负下标 —— 与 Tab2 卡组实现无限循环的写法一致。
 *
 * @param item  待填充的显示模型
 * @param index 本站下标（不是序号 id —— 序号是 1 起的，两者差 1）
 */
function fillNeighborPhotos(item: ZonesItem, index: number): void {
  const total: number = stations.length;
  if (total <= 0) {
    return;
  }
  // 站点太少时半径要收一收，否则会把同一站重复塞进列表。
  const radius: number = Math.min(Const.DETAIL_PHOTO_NEIGHBOR_RADIUS, Math.floor((total - 1) / 2));
  for (let offset = -radius; offset <= radius; offset++) {
    const raw: number = index + offset;
    const target: number = ((raw % total) + total) % total;
    item.photoList.push(stations[target].photo);
    item.photoNameList.push(stations[target].name);
    item.photoSeqList.push(stations[target].seq);
    // 中心那张（offset = 0）就是本站，记下它排在第几位，
    // 详情页一进来就把视角停在这一张上。
    if (offset === 0) {
      item.photoFocusIndex = item.photoList.length - 1;
    }
  }
}

/**
 * 装配全程总览（里程 / 爬升 / 用时文案 / 起止时刻）。
 */
function buildSummary(): ZonesSummary {
  const summary = new ZonesSummary();
  summary.count = stations.length;
  summary.distance = routeSummary.distance;
  summary.ascent = routeSummary.ascent;
  summary.durationMinutes = routeSummary.durationMinutes;
  summary.durationText = `${Math.floor(routeSummary.durationMinutes / 60)} 时 ${routeSummary.durationMinutes % 60} 分`;
  summary.startTime = routeSummary.startTime;
  summary.summitTime = routeSummary.summitTime;
  return summary;
}
