/**
 * 站点介绍单元类（对应老师参考工程的 ZonesItem）。
 *
 * 沿途站点页（Tab2）展示「一个站点」需要的全部数据都收敛在这里，
 * 页面只读字段、不做任何换算 —— 类型名、类型配色、图标、相对爬升、
 * 时间轴进度、海拔里程文案，都在装配时（ZonesViewModel.buildZonesItem）一次算好。
 *
 * 与老师参考工程 ZonesItem 的字段对应关系：
 *   id                  -> id              站点序号（原为区域编号，取单个 / 路由传参用）
 *   title               -> title           站点全名
 *   subTitle            -> subTitle        站点类型（起点 / 补给点 / 险段 / 峰顶 / 关隘）
 *   createTime          -> arriveTime      建议到达时刻（原为建成年代）
 *   content[]           -> tip / intro     两段正文（夜爬提示 + 站点简介）
 *   thumbnail/swiperPic -> photo           实景照片（缩略图与大图共用同一张）
 *   titleIcon           -> titleIcon       站点类型图标（SVG，可染色）
 *   buildingInformation -> metaText        海拔 / 里程 / 爬升文案（原为建筑面积文本）
 *   backgroundColor     -> backgroundColor 站点类型主题色
 *   imgList             -> photoList       详情页「沿途影像」横滑卡组（本站 + 前后邻站）
 *
 * 另补了参考工程没有、但本项目页面要用到的量化字段：
 *   ascent（相对上一站爬升）、progress（时间轴进度）、key（是否关键站点），
 *   以及详情页要用的 photoNameList / photoSeqList / photoFocusIndex。
 *
 * 站点数据不在本文件里另写一份：字段值统一由 ZonesViewModel 从
 * viewmodel/MapModel.stations 派生，保证「路线图 / 沿途站点 / 夜爬时刻 / 站点详情」
 * 四处永远用的是同一份数据。
 *
 * @version 1.1
 */
import { StationKind } from './MapModel';

export default class ZonesItem {
  /**
   * 站点序号（1 起，与地图地标、路线折线顺序一致）。
   */
  id: number = 0;
  /**
   * 站点完整名称。
   */
  title: string = '';
  /**
   * 站点类型中文名（卡片标题旁的标签）。
   */
  subTitle: string = '';
  /**
   * 地图标记上用的短名（2~4 字，留给地图标记 / 搜索宫格复用）。
   */
  shortTitle: string = '';
  /**
   * 站点类型原始值（需要按类型判断时用）。
   */
  kind: StationKind = StationKind.PASS;
  /**
   * 站点类型主题色：序号圆点、类型标签、当前站点边框高亮都用它。
   */
  backgroundColor: string = '#FFFFFF';
  /**
   * 站点类型图标（必须是 SVG —— PNG 不能用 fillColor 染色）。
   */
  titleIcon: Resource = $r('app.media.ic_hs_mark_pass');
  /**
   * 建议到达时刻（HH:MM）。
   */
  arriveTime: string = '';
  /**
   * 海拔（米）。
   */
  altitude: number = 0;
  /**
   * 距起点累计里程（公里）。
   */
  distance: number = 0;
  /**
   * 相对上一个站点的爬升（米）；首站没有上一站，记 0。
   */
  ascent: number = 0;
  /**
   * 现成的海拔 / 里程 / 爬升文案（原参考工程的 buildingInformation）。
   */
  metaText: string = '';
  /**
   * 该站点在整条夜爬时间轴上的进度（0 ~ 1）。
   */
  progress: number = 0;
  /**
   * 是否为关键站点（起点 / 三大险段 / 主峰 / 关隘）。
   */
  key: boolean = false;
  /**
   * 站点实景照片。
   */
  photo: Resource = $r('app.media.hs_spot_01');
  /**
   * 一句话夜爬提示。
   */
  tip: string = '';
  /**
   * 站点简介。
   */
  intro: string = '';
  /**
   * 详情页「沿途影像」横向卡组的照片（对应参考工程的 imgList）。
   *
   * 顺序就是夜爬顺序：前 N 站 → 本站 → 后 N 站（首尾按环上顺序回绕）。
   * 本项目每个站点只有一张实景照，一张图撑不起可滑动的卡组，
   * 所以在这里把邻站的照片一并装配好 —— 页面拿到的仍然是「现成可用」的数据。
   */
  photoList: Resource[] = [];
  /**
   * 与 photoList 一一对应的站点名（卡面下方标注）。
   */
  photoNameList: string[] = [];
  /**
   * 与 photoList 一一对应的站点序号（卡面角标）。
   */
  photoSeqList: number[] = [];
  /**
   * 本站是 photoList 里的第几张。
   *
   * 详情页一进「沿途影像」就把视角停在本站上，而不是从第一张邻站开始滑。
   */
  photoFocusIndex: number = 0;
}
