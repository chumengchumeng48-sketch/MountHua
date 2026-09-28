/**
 * 华山夜爬路线数据模型。
 *
 * 底图 ic_hs_map.png（1200 x 1600，华山夜景俯视插画）为等比缩放的俯视图：
 * 画面下方是华山峪口（玉泉院），中上部是华山花岗岩峰林，山间有一条亮着
 * 灯火的山谷自下而上贯穿。
 *
 * 本文件里的 15 个站点即为「夜爬华山」经典徒步线路，自古华山一条路：
 *   玉泉院 → 五里关 → 莎萝坪 → 毛女洞 → 青柯坪 → 回心石 → 千尺幢 →
 *   百尺峡 → 老君犁沟 → 北峰 → 擦耳崖 → 苍龙岭 → 五云峰 → 金锁关 →
 *   东峰观日台
 *
 * 每个站点记录：
 * - pinX / pinY：站点在底图上的像素坐标（地图定位、搜索后居中用）；
 * - altitude / distance / time：海拔（米）、距起点累计里程（公里）、建议到达时刻；
 * - kind：站点类型，决定标记配色（起点 / 补给 / 险段 / 峰顶 / 关隘）；
 * - tip：一句话夜爬提示；intro：导览页简介。
 *
 * 注意：海拔、里程与时刻均为示意数据，实际以景区公告为准。
 */
import { CommonConstants as Const } from '../commons/constants/CommonConstants';

/**
 * 站点类型。
 */
export enum StationKind {
  /** 起点 / 山门 */
  START = 1,
  /** 补给点（有客栈、卫生间，可休整） */
  SUPPLY = 2,
  /** 险段（陡峭石阶、铁链路段，需手脚并用） */
  DANGER = 3,
  /** 峰顶 / 观景台 */
  PEAK = 4,
  /** 关隘 / 途中节点 */
  PASS = 5
}

/**
 * 夜爬站点。
 */
export interface IStation {
  /** 序号，从 1 开始，与建议到达顺序一致。 */
  seq: number;
  /** 完整名称。 */
  name: string;
  /** 地图标记上的短名（2~4 字，避免压盖底图）。 */
  short: string;
  kind: StationKind;
  /** 海拔（米）。 */
  altitude: number;
  /** 距起点累计里程（公里）。 */
  distance: number;
  /** 建议到达时刻（HH:MM）。 */
  time: string;
  /** 底图像素坐标。 */
  pinX: number;
  pinY: number;
  /** 是否为关键站点：低倍率下也常显名称，其余站点放大后才显示名称。 */
  key: boolean;
  /** 站点实景照片资源（来自 Wikimedia Commons，授权见 .workbuddy/gen/credits.md）。 */
  photo: Resource;
  /** 一句话夜爬提示。 */
  tip: string;
  /** 导览页简介。 */
  intro: string;
}

/**
 * 15 个夜爬站点（按夜爬先后顺序）。
 */
export const stations: Array<IStation> = [
  {
    seq: 1, name: '玉泉院（起点）', short: '玉泉院', kind: StationKind.START,
    altitude: 400, distance: 0, time: '21:30', pinX: 782, pinY: 1505, key: true,
    photo: $r('app.media.hs_spot_01'),
    tip: '夜爬起点，21:00 前后集合出发，院前可寄存行李、补足饮水。',
    intro: '华山峪口，自古「华山一条路」由此入山。华山海拔 400 米的起点，也是夜爬队伍集合、寄存大件行李与做最后补给的地方。'
  },
  {
    seq: 2, name: '五里关', short: '五里关', kind: StationKind.PASS,
    altitude: 570, distance: 2.6, time: '22:10', pinX: 798, pinY: 1315, key: false,
    photo: $r('app.media.hs_spot_02'),
    tip: '进峪后第一道关隘，山路开始拔高，节奏放慢、别急。',
    intro: '入峪第一道关隘，两侧山石夹峙。过了五里关，山路正式从缓坡变成连续上升的石阶，也是很多人第一次怀疑体力的地方。'
  },
  {
    seq: 3, name: '莎萝坪', short: '莎萝坪', kind: StationKind.SUPPLY,
    altitude: 720, distance: 4.6, time: '22:50', pinX: 797, pinY: 1222, key: false,
    photo: $r('app.media.hs_spot_03'),
    tip: '树荫平缓段，适合 5 分钟短休；溪谷湿滑，注意脚下。',
    intro: '峪道中段难得的平缓开阔地，古时有莎萝树而得名。夜里能听见很响的溪谷水声，是夜爬途中相对舒服的一段。'
  },
  {
    seq: 4, name: '毛女洞', short: '毛女洞', kind: StationKind.PASS,
    altitude: 950, distance: 6.4, time: '23:40', pinX: 848, pinY: 1052, key: false,
    photo: $r('app.media.hs_spot_04'),
    tip: '台阶变陡，进入连续爬升，调整呼吸别抢步。',
    intro: '传说秦时宫女毛女避乱隐居于此，岩壁留有洞龛。从这里开始连续爬升，海拔快速抬升，是夜爬体力的第一道分水岭。'
  },
  {
    seq: 5, name: '青柯坪', short: '青柯坪', kind: StationKind.SUPPLY,
    altitude: 1180, distance: 8.0, time: '00:20', pinX: 905, pinY: 940, key: true,
    photo: $r('app.media.hs_spot_05'),
    tip: '最重要补给点：有客栈和卫生间，吃口热食、检查头灯电量。',
    intro: '华山峪道最重要的中途补给点，有客栈、小卖部和卫生间。夜爬常见安排是到这里吃碗热面、把水壶灌满，为接下来的三大险段做准备。'
  },
  {
    seq: 6, name: '回心石', short: '回心石', kind: StationKind.PASS,
    altitude: 1290, distance: 8.9, time: '00:50', pinX: 846, pinY: 900, key: false,
    photo: $r('app.media.hs_spot_06'),
    tip: '「过了回心石，再无回头路」——体力不支者在此折返。',
    intro: '一块横在路中的巨石，旧时体力不支的登山者多在此回心转意、原路下山，因此得名。过了它，前方便是连续的险段。'
  },
  {
    seq: 7, name: '千尺幢', short: '千尺幢', kind: StationKind.DANGER,
    altitude: 1370, distance: 9.5, time: '01:10', pinX: 775, pinY: 864, key: true,
    photo: $r('app.media.hs_spot_07'),
    tip: '第一道险关：石阶凿在垂直岩缝里，只能放下半只脚掌，务必双手抓链、稳定换步。',
    intro: '华山三大险道之一，石阶直接凿在近乎垂直的岩缝中，仅容半只脚掌，需双手拉住铁链攀爬。夜爬时队伍会在此排队，注意上方落石。'
  },
  {
    seq: 8, name: '百尺峡', short: '百尺峡', kind: StationKind.DANGER,
    altitude: 1440, distance: 9.9, time: '01:30', pinX: 706, pinY: 869, key: false,
    photo: $r('app.media.hs_spot_08'),
    tip: '岩壁夹峙的陡峡，碎石多、易打滑，手套此时最有用。',
    intro: '千尺幢之上的又一道陡峡，两侧岩壁夹峙近乎贴身。石阶窄且多碎石，下行队伍与上行队伍容易互相影响，通过时不要并行。'
  },
  {
    seq: 9, name: '老君犁沟', short: '老君犁沟', kind: StationKind.DANGER,
    altitude: 1500, distance: 10.6, time: '01:50', pinX: 656, pinY: 877, key: false,
    photo: $r('app.media.hs_spot_09'),
    tip: '沟槽窄陡多碎石，是三大险段的最后一道，稳住节奏。',
    intro: '相传老子以犁开山，留下这道沟槽似的山道。沟窄坡陡、碎石松动，是上山前最后的险段，过了它北峰就在眼前。'
  },
  {
    seq: 10, name: '北峰·云台峰', short: '北峰', kind: StationKind.PEAK,
    altitude: 1614, distance: 12.5, time: '02:40', pinX: 612, pinY: 974, key: true,
    photo: $r('app.media.hs_spot_10'),
    tip: '夜爬第一座主峰，通常凌晨 2~3 点抵达；峰顶风大，加衣后短休。',
    intro: '华山五峰中的最低一峰，海拔 1614 米，是三峰环抱、一峰独立的「云台峰」。绝大多数夜爬队伍在凌晨两三点到这里，休整后继续向金锁关方向前进。'
  },
  {
    seq: 11, name: '擦耳崖', short: '擦耳崖', kind: StationKind.DANGER,
    altitude: 1660, distance: 13.0, time: '03:10', pinX: 471, pinY: 735, key: false,
    photo: $r('app.media.hs_spot_11'),
    tip: '崖壁狭窄须侧身贴壁而行，背包容易擦岩，收好相机和水壶。',
    intro: '山路被压到极窄，一侧是崖壁、一侧是深谷，行走时肩背包几乎贴着岩石，故名擦耳崖。通过时注意保护随身物品。'
  },
  {
    seq: 12, name: '苍龙岭', short: '苍龙岭', kind: StationKind.DANGER,
    altitude: 1720, distance: 13.4, time: '03:40', pinX: 330, pinY: 508, key: true,
    photo: $r('app.media.hs_spot_12'),
    tip: '华山最著名的险道：一条石脊悬在两侧深谷之上，夜行只看脚下灯光往前走。',
    intro: '华山最著名的一段险道，石脊如苍龙伏地，两侧皆是深谷。白天走已足够惊心，夜爬时只能看见头灯照亮的窄窄一线路，反倒不容易害怕。'
  },
  {
    seq: 13, name: '五云峰', short: '五云峰', kind: StationKind.PEAK,
    altitude: 1830, distance: 13.9, time: '04:10', pinX: 483, pinY: 326, key: false,
    photo: $r('app.media.hs_spot_13'),
    tip: '若赶上云海，这里是第一处值得停下来的观景台。',
    intro: '苍龙岭之上的观景平台，视野开阔。运气好的时候，凌晨的云海会在脚下翻滚，是夜爬途中第一处真正值得停下拍照的地方。'
  },
  {
    seq: 14, name: '金锁关', short: '金锁关', kind: StationKind.PASS,
    altitude: 1950, distance: 14.2, time: '04:40', pinX: 453, pinY: 272, key: true,
    photo: $r('app.media.hs_spot_14'),
    tip: '华山「关门」，过此即进入五峰环抱的天上台，离终点只剩最后一段。',
    intro: '旧时上下华山的必经关口，两侧铁索挂满游客留下的金锁。过了金锁关，就进入五峰环抱的核心景区，向中峰、东峰方向最后一段上升。'
  },
  {
    seq: 15, name: '东峰·观日台', short: '东峰', kind: StationKind.PEAK,
    altitude: 2096, distance: 15.3, time: '05:20', pinX: 349, pinY: 134, key: true,
    photo: $r('app.media.hs_spot_15'),
    tip: '全程终点：凌晨 4:30 前后到达占位，等日出把云海染成金红色。',
    intro: '海拔 2096 米的东峰又称朝阳峰，观日台是华山看日出的首选位置。夜爬的全部意义，就是在凌晨 5 点前后站上这里，看第一缕阳光把云海染成金红色。'
  }
];

/**
 * 站点类型对应的地标图标（SVG，地图标记与面板宫格共用）。
 */
export function stationMarkIcon(kind: StationKind): Resource {
  if (kind === StationKind.START) {
    return $r('app.media.ic_hs_mark_start');
  }
  if (kind === StationKind.SUPPLY) {
    return $r('app.media.ic_hs_mark_supply');
  }
  if (kind === StationKind.DANGER) {
    return $r('app.media.ic_hs_mark_danger');
  }
  if (kind === StationKind.PEAK) {
    return $r('app.media.ic_hs_mark_peak');
  }
  return $r('app.media.ic_hs_mark_pass');
}

/**
 * 站点类型对应的标记颜色（取自 CommonConstants，保持单一数据源）。
 */
export function stationKindColor(kind: StationKind): string {
  if (kind === StationKind.START) {
    return Const.KIND_START_COLOR;
  }
  if (kind === StationKind.SUPPLY) {
    return Const.KIND_SUPPLY_COLOR;
  }
  if (kind === StationKind.DANGER) {
    return Const.KIND_DANGER_COLOR;
  }
  if (kind === StationKind.PEAK) {
    return Const.KIND_PEAK_COLOR;
  }
  return Const.KIND_PASS_COLOR;
}

/**
 * 站点类型中文名（导览页 / 时刻页标签用）。
 */
export function stationKindName(kind: StationKind): string {
  if (kind === StationKind.START) {
    return '起点';
  }
  if (kind === StationKind.SUPPLY) {
    return '补给点';
  }
  if (kind === StationKind.DANGER) {
    return '险段';
  }
  if (kind === StationKind.PEAK) {
    return '峰顶';
  }
  return '关隘';
}

/**
 * 生成路线折线（底图像素坐标）。
 *
 * 沿线两个站点之间插入两个带法向偏移的中间点，让折线呈自然的手绘盘山走势，
 * 同时保证折线严格穿过每一个站点坐标（不能只靠样条平滑，否则会掠过站点）。
 */
function buildRoutePath(): Array<Array<number>> {
  const path: Array<Array<number>> = [];
  const count = stations.length;
  const amp = Const.ROUTE_WAVE_AMP;
  for (let i = 0; i < count - 1; i++) {
    const ax = stations[i].pinX;
    const ay = stations[i].pinY;
    const bx = stations[i + 1].pinX;
    const by = stations[i + 1].pinY;
    const dx = bx - ax;
    const dy = by - ay;
    const len = Math.sqrt(dx * dx + dy * dy);
    // 单位法向量：把中间点推向路径两侧，形成盘山折线。
    const nx = len > 0 ? -dy / len : 0;
    const ny = len > 0 ? dx / len : 0;
    const sign = i % 2 === 0 ? 1 : -1;
    path.push([ax, ay]);
    path.push([ax + dx * 0.35 + nx * amp * sign, ay + dy * 0.35 + ny * amp * sign]);
    path.push([ax + dx * 0.72 - nx * amp * 0.6 * sign, ay + dy * 0.72 - ny * amp * 0.6 * sign]);
  }
  path.push([stations[count - 1].pinX, stations[count - 1].pinY]);
  return path;
}

/**
 * 路线折线点位（单位：底图像素）。
 */
export const routePath: Array<Array<number>> = buildRoutePath();

/**
 * 全程汇总数据（时刻页顶部总览用）。
 */
export interface IRouteSummary {
  /** 全程里程（公里）。 */
  distance: number;
  /** 累计爬升（米）。 */
  ascent: number;
  /** 出发时刻。 */
  startTime: string;
  /** 预计登顶（东峰）时刻。 */
  summitTime: string;
  /** 预计用时（分钟）。 */
  durationMinutes: number;
  /** 出发地海拔（米）。 */
  minAltitude: number;
  /** 终点海拔（米）。 */
  maxAltitude: number;
}

export const routeSummary: IRouteSummary = {
  distance: stations[stations.length - 1].distance,
  ascent: stations[stations.length - 1].altitude - stations[0].altitude,
  startTime: stations[0].time,
  summitTime: stations[stations.length - 1].time,
  durationMinutes: Const.CLIMB_DURATION_MINUTES,
  minAltitude: stations[0].altitude,
  maxAltitude: stations[stations.length - 1].altitude
};

/**
 * 把 'HH:MM' 换算成当天分钟数。
 */
export function timeTextToMinutes(text: string): number {
  const parts = text.split(':');
  return Number(parts[0]) * 60 + Number(parts[1]);
}

/**
 * 夜爬进度（0 ~ 1，超过 1 视为已完成，负数表示还没出发）。
 *
 * 夜爬跨越午夜：21:30 出发、次日 05:20 到东峰，因此把 00:00 ~ 12:00 之间的
 * 当前时刻加上一天再计算，保证时间轴单调递增。
 */
export function climbProgress(now: Date): number {
  const startMin = timeTextToMinutes(routeSummary.startTime);
  const endMin = timeTextToMinutes(routeSummary.summitTime) + 24 * 60;
  let curMin = now.getHours() * 60 + now.getMinutes();
  if (curMin < 12 * 60) {
    curMin += 24 * 60;
  }
  if (curMin <= startMin) {
    return 0;
  }
  return Math.min((curMin - startMin) / (endMin - startMin), 1);
}

/**
 * 单个站点在整条时间轴上的进度（0 ~ 1），按建议到达时刻线性换算。
 */
export function stationProgress(station: IStation): number {
  const startMin = timeTextToMinutes(routeSummary.startTime);
  const endMin = timeTextToMinutes(routeSummary.summitTime) + 24 * 60;
  let cur = timeTextToMinutes(station.time);
  if (cur < 12 * 60) {
    cur += 24 * 60;
  }
  const p = (cur - startMin) / (endMin - startMin);
  return Math.min(Math.max(p, 0), 1);
}

/**
 * 当前进度下最后一个已经过的站点下标（用于「已过 xx」文案）。
 */
export function reachedStationIndex(progress: number): number {
  let index = 0;
  for (let i = 0; i < stations.length; i++) {
    if (progress >= stationProgress(stations[i])) {
      index = i;
    }
  }
  return index;
}

/**
 * 路线上按累计长度取进度点位置（单位：底图像素）。
 *
 * 注意不能按「站点数量」等分，因为各段实际长度不同，等分会让进度点跳变。
 */
export function routePointAt(progress: number): Array<number> {
  const pts = routePath;
  if (pts.length === 0) {
    return [0, 0];
  }
  const segLen: Array<number> = [];
  let total = 0;
  for (let i = 0; i < pts.length - 1; i++) {
    const len = Math.sqrt(Math.pow(pts[i + 1][0] - pts[i][0], 2) + Math.pow(pts[i + 1][1] - pts[i][1], 2));
    segLen.push(len);
    total += len;
  }
  if (total <= 0) {
    return [pts[0][0], pts[0][1]];
  }
  const target = Math.min(Math.max(progress, 0), 1) * total;
  let walked = 0;
  for (let i = 0; i < segLen.length; i++) {
    if (walked + segLen[i] >= target) {
      const t = segLen[i] > 0 ? (target - walked) / segLen[i] : 0;
      return [
        pts[i][0] + (pts[i + 1][0] - pts[i][0]) * t,
        pts[i][1] + (pts[i + 1][1] - pts[i][1]) * t
      ];
    }
    walked += segLen[i];
  }
  return [pts[pts.length - 1][0], pts[pts.length - 1][1]];
}
