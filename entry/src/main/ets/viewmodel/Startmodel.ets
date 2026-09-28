import { CommonConstants as Const } from '../commons/constants/CommonConstants';

/**
 * 启动页时段模型。
 *
 * 一天分成四档，每档用一组自己的轮播图 + 一张自己的欢迎页渐变背景，
 * 因此无论在什么时刻打开 App，启动页的光线都与当下时间对得上。
 *
 * 分界时刻（常量见 CommonConstants）：
 * - 晨光 MORNING  08:12 起 —— 薄雾未散、山脊挂暖金
 * - 正午 NOON     12:17 起 —— 天光通透、岩石发白
 * - 黄昏 DUSK     17:20 起 —— 云海染橙红、天色转紫
 * - 夜晚 NIGHT    20:08 起 —— 冷蓝星空、谷底灯火
 *
 * 00:00 ~ 08:11 归到「夜晚」档（延续前一晚的夜色，不是第二天清晨）。
 *
 * 每档三张图为同一组华山场景（日出云海 / 悬崖栈道 / 五峰全景）的
 * 同色系调色版本，资源名 hs_scene{1,2,3}_{morning,noon,dusk,night}.jpg。
 * 例外：晨光档三张已换成用户实拍的华山日出照片（05:37 天光未亮 / 05:41 霞光 / 05:41 日出），
 * 因此晨光档不再由 .workbuddy/tools/hs_assets.py 生成，改由 hs_morning_swap.py 维护。
 */
export enum StartPhase {
  MORNING = 0,
  NOON = 1,
  DUSK = 2,
  NIGHT = 3
}

/**
 * 单个时段档位：名称、一句话提示、轮播图组、欢迎页背景。
 */
export interface IStartPhase {
  phase: StartPhase;
  name: string;
  hint: string;
  images: Resource[];
  bg: Resource;
}

/**
 * 四档时段数据（顺序与 StartPhase 枚举一一对应）。
 */
export const startPhases: Array<IStartPhase> = [
  {
    phase: StartPhase.MORNING,
    name: '晨光',
    hint: '晨雾未散，峪道初醒',
    images: [
      $r('app.media.hs_scene1_morning'),
      $r('app.media.hs_scene2_morning'),
      $r('app.media.hs_scene3_morning')
    ],
    bg: $r('app.media.splash_bg_morning')
  },
  {
    phase: StartPhase.NOON,
    name: '正午',
    hint: '日头正盛，石阶发烫',
    images: [
      $r('app.media.hs_scene1_noon'),
      $r('app.media.hs_scene2_noon'),
      $r('app.media.hs_scene3_noon')
    ],
    bg: $r('app.media.splash_bg_noon')
  },
  {
    phase: StartPhase.DUSK,
    name: '黄昏',
    hint: '暮色四合，正是出发时',
    images: [
      $r('app.media.hs_scene1_dusk'),
      $r('app.media.hs_scene2_dusk'),
      $r('app.media.hs_scene3_dusk')
    ],
    bg: $r('app.media.splash_bg_dusk')
  },
  {
    phase: StartPhase.NIGHT,
    name: '夜晚',
    hint: '星河在顶，灯火在谷',
    images: [
      $r('app.media.hs_scene1_night'),
      $r('app.media.hs_scene2_night'),
      $r('app.media.hs_scene3_night')
    ],
    bg: $r('app.media.splash_bg_night')
  }
];

/**
 * 按当前时刻选出所处时段档位。
 *
 * 判定用「从 00:00 起算的分钟数」比较，因此能精确到分（如 12:17 这一分钟）。
 */
export function currentStartPhase(now: Date): IStartPhase {
  const cur = now.getHours() * 60 + now.getMinutes();
  if (cur >= Const.SPLASH_NIGHT_MINUTE) {
    return startPhases[StartPhase.NIGHT];
  }
  if (cur >= Const.SPLASH_DUSK_MINUTE) {
    return startPhases[StartPhase.DUSK];
  }
  if (cur >= Const.SPLASH_NOON_MINUTE) {
    return startPhases[StartPhase.NOON];
  }
  if (cur >= Const.SPLASH_DAWN_MINUTE) {
    return startPhases[StartPhase.MORNING];
  }
  // 00:00 ~ 08:11：延续前一晚的夜色。
  return startPhases[StartPhase.NIGHT];
}

/**
 * 当前时刻文案（HH:mm，补零）。
 */
export function clockText(now: Date): string {
  const h = now.getHours();
  const m = now.getMinutes();
  return `${h < 10 ? '0' : ''}${h}:${m < 10 ? '0' : ''}${m}`;
}
