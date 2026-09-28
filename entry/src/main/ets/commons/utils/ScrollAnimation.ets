/**
 * 详情页的滚动联动换算（对齐老师参考工程的 commons/utils/Animation.ets）。
 *
 * 老师那个类的三个方法里，本文件只保留一个真正必要的：`controlImageScale`。
 * 其余两个没有搬过来，原因写在这里，免得后面又照着补回去：
 *   - `changeTitlePosition` 老师自己标注「未用到暂时保留该字段」；
 *   - `changeTitleIcon` 靠 `offsetSum` 落在 500 / 1000 / 1500 这几条写死的阈值上
 *     判断当前分区 —— 那几个数是他页面里三段的固定屏高，本项目分区高度不同，
 *     照搬会错位。本项目改成「每个分区各自带一个吸顶标题条」，
 *     吸顶条在越过分区边界时换内容，不需要任何阈值判断。
 *
 * 本文件是**纯计算**：只读常量、只改传进来的状态对象，不碰界面上下文
 * （animateTo / scrollTo 这类需要 UIContext 的动作留在页面里做）。
 *
 * @version 1.0
 */
import { CommonConstants as Const } from '../constants/CommonConstants';
import { AnimationItem } from '../../viewmodel/AnimationItem';

export class ScrollAnimation {
  /**
   * 把「列表本帧想走的位移」重新分配给首图：首图先收缩 / 先长回，剩下的才交给列表。
   *
   * 用法：放在 List 的 onScrollFrameBegin 里，返回值就是列表本帧实际消费的位移。
   *   .onScrollFrameBegin((offset: number) => {
   *     return { offsetRemain: ScrollAnimation.controlHeroScale(this.anim, offset) };
   *   })
   *
   * 分配规则：
   *   - 向上滑（offset > 0）：先压首图。首图已经到底（heroPercent = 下限）后，
   *     剩下的位移才让列表滚 —— 于是观感是「首图被推上去、正文跟着出来」。
   *   - 向下滑（offset < 0）：先把首图拉回满屏，拉满之后列表才继续往回滚。
   * 两个方向都留了「剩下的位移」，所以首图到底 / 到顶之后列表能正常滚动，
   * 不会出现被卡住拉不动的情况。
   *
   * @param item   动画状态（首图百分比会被就地更新）
   * @param offset 列表本帧的位移（vp，向上为正）
   * @returns 列表本帧实际消费的位移（vp）
   */
  static controlHeroScale(item: AnimationItem, offset: number): number {
    // 列表还没量到高度（或本来就等于下限）时不做换算，退化成普通滚动。
    // screenHeight 为 0 还会让下面的 perPercent 变成 0 → 除以 0，所以必须挡住。
    if (item.screenHeight <= 0 || offset === 0) {
      return offset;
    }
    const span: number = Const.DETAIL_HERO_MAX_PERCENT - Const.DETAIL_HERO_MIN_PERCENT;
    // 首图高度每变化 1 个百分点，手指需要滑过的位移（vp）。
    const perPercent: number = item.screenHeight * Const.DETAIL_HERO_SCROLL_FULL / span;
    if (perPercent <= 0) {
      return offset;
    }

    if (offset > 0) {
      // 向上滑：先收缩首图，最多收缩到下限。
      const shrinkable: number = item.heroPercent - Const.DETAIL_HERO_MIN_PERCENT;
      const want: number = offset / perPercent;
      const shrink: number = Math.min(want, shrinkable);
      item.heroPercent = item.heroPercent - shrink;
      item.topButtonOpacity = ScrollAnimation.buttonOpacity(item.heroPercent);
      return offset - shrink * perPercent;
    }

    // 向下滑：先让首图长回满屏，最多长到上限。
    const growable: number = Const.DETAIL_HERO_MAX_PERCENT - item.heroPercent;
    const want: number = -offset / perPercent;
    const grow: number = Math.min(want, growable);
    item.heroPercent = item.heroPercent + grow;
    item.topButtonOpacity = ScrollAnimation.buttonOpacity(item.heroPercent);
    return offset + grow * perPercent;
  }

  /**
   * 首图高度 → 「回到首图」按钮的透明度。
   *
   * 首图满屏时按钮完全透明（此时页面就在首图，按钮没意义），
   * 随着首图收缩线性显现，收缩到底时为 1。
   */
  static buttonOpacity(heroPercent: number): number {
    const span: number = Const.DETAIL_HERO_MAX_PERCENT - Const.DETAIL_HERO_MIN_PERCENT;
    if (span <= 0) {
      return 0;
    }
    // 先算「缩掉了多少比例」：满屏 0、到底 1。
    const shrunk: number = (Const.DETAIL_HERO_MAX_PERCENT - heroPercent) / span;
    return Math.max(0, Math.min(1, shrunk));
  }
}
