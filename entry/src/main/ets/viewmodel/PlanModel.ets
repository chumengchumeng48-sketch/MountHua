/**
 * 夜爬准备数据模型（Tab4「夜爬准备」与 Tab3 底部的贴士共用）。
 */

/**
 * 装备清单项。
 */
export interface IGearItem {
  name: string;
  /** 为什么带它（一句话说明）。 */
  reason: string;
  /** 是否必需（必需项在界面上加「必带」标记）。 */
  required: boolean;
}

export const gearList: Array<IGearItem> = [
  { name: '头灯 / 手电 + 备用电池', reason: '夜爬全程靠照明，手机手电续航不够，且需要腾出双手抓铁链。', required: true },
  { name: '防滑手套', reason: '千尺幢、老君犁沟等险段必须抓铁链，夜里铁链又冷又滑。', required: true },
  { name: '防滑徒步鞋', reason: '石阶多碎石与露水，运动鞋底太软容易打滑。', required: true },
  { name: '冲锋衣 / 抓绒外套', reason: '山上夜间比山下低 10℃ 以上，峰顶风大。', required: true },
  { name: '1.5L 以上饮水', reason: '山上补给点夜间多已关闭，青柯坪可补水但价格偏高。', required: true },
  { name: '高热量零食', reason: '巧克力、能量胶、牛肉干，凌晨补糖能明显提神。', required: false },
  { name: '身份证', reason: '进山购票与安检需要。', required: true },
  { name: '充电宝', reason: '低温下电量掉得快，拍照与照明都靠它。', required: true },
  { name: '护膝 / 登山杖', reason: '下行对膝盖压力最大，护膝能明显减轻酸痛。', required: false },
  { name: '轻便雨衣', reason: '山区天气变化快，一次性雨衣比伞实用。', required: false },
  { name: '纸巾 / 湿巾', reason: '沿途擦手、清洁，山下卫生间条件有限。', required: false },
  { name: '少量现金', reason: '山上信号不稳定，移动支付可能失败。', required: false }
];

/**
 * 安全须知。
 */
export interface ISafetyTip {
  title: string;
  content: string;
}

export const safetyTips: Array<ISafetyTip> = [
  {
    title: '先看天气再决定',
    content: '雨、雪、大风天气不要夜爬，石阶结冰或湿滑时险段风险极高。出发前查看华阴市天气预报。'
  },
  {
    title: '结伴同行',
    content: '至少两人一组，提前把行程告知家人；夜里独自在险段失去行动能力会非常被动。'
  },
  {
    title: '险段规矩要守',
    content: '千尺幢、百尺峡、老君犁沟、苍龙岭全程手扶铁链，不并行、不超越、不停留拍照。'
  },
  {
    title: '控制节奏',
    content: '夜里看不见山顶，最容易一开始走太快。按每小时 1.5~2 公里的节奏推进，青柯坪与北峰各休整一次。'
  },
  {
    title: '保暖与补水',
    content: '停下来的瞬间最容易失温，休息时先加衣；小口多次饮水，不要等口渴再喝。'
  },
  {
    title: '紧急情况',
    content: '遇险先靠边、开灯、呼救，拨打报警电话 110 / 急救电话 120；景区救援与服务信息以官方最新公告为准。'
  }
];

/**
 * 观日信息（夜爬的最终目的）。
 */
export interface ISunriseInfo {
  /** 观日台名称。 */
  spot: string;
  /** 海拔（米）。 */
  altitude: number;
  /** 建议占位时刻。 */
  arriveTime: string;
  /** 夏令时前后日出的大致时间区间。 */
  sunriseRange: string;
  /** 提示。 */
  tip: string;
}

export const sunriseInfo: ISunriseInfo = {
  spot: '东峰 · 观日台',
  altitude: 2096,
  arriveTime: '04:30',
  sunriseRange: '05:20 ~ 05:50',
  tip: '观日台空间有限，凌晨 4:30 之前到达占位更稳；日出前 10 分钟天空色彩变化最快。'
};
