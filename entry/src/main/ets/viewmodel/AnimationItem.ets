/**
 * 详情页动画状态单元（对齐老师参考工程的 AnimationItem 显示模型）。
 *
 * 详情页的「首图随滚动收缩」「回到首图按钮渐显」这类联动，需要把几个状态
 * 在列表和各个子组件之间共享，并且每帧都会变。把它们收进这一个 @Observed 类：
 *   - 用 @ObjectLink 把本对象传给子组件时，首图高度变化只会重渲用到它的那个节点，
 *     不会连累整个列表（详情页一屏有好几个分区，整页重渲会明显卡顿）；
 *   - 本类只存状态、不做计算：滚动位移 → 首图高度 / 按钮透明度的换算都在
 *     commons/utils/ScrollAnimation 里，页面只负责把结果喂回来。
 *
 * 与老师参考工程的字段对应关系：
 *   screenHeight     -> screenHeight      列表可视高度（vp），位移换算的基准
 *   imageHeight      -> heroPercent       首图高度（占可视高度的百分比）
 *   arrowIconOpacity -> topButtonOpacity  「回到首图」按钮的透明度
 *   scrollerForList  -> scrollerForList   列表滚动控制器（回顶用）
 *   offsetSum        -> offsetSum         累计滚动位移（仅记录，便于调试）
 *
 * 老师原版里的三个字段没有保留，原因都是同一个：它们服务于他那一页的具体做法，
 * 本项目换了做法，留着就是无引用的死字段。
 *   - geographicPicType：他按滚动位移切换地理配图的明暗两张图；本项目只有一套图。
 *   - currentListIndex：他靠 List.onScrollIndex 判断滚到第几段；本项目改成
 *     每个分区各自带吸顶标题条（见 SpotDetailPage.build），不需要跨分区记下标。
 *   - scaleIcon / iconTitle：他并排画三个图标、靠缩放数组切换显隐；本项目吸顶条
 *     只画当前分区那一个图标，不需要缩放数组。
 *
 * @version 1.0
 */
@Observed
export class AnimationItem {
  /**
   * 列表可视高度（单位：vp）。
   *
   * 由 DeviceScreen.getDeviceHeight() 在进入页面时给初值，列表量到真实尺寸后
   * 再用 onAreaChange 校正（折叠屏展开 / 分屏时会更准）。
   */
  screenHeight: number = 0;
  /**
   * 首图高度（占可视高度的百分比），取值区间见
   * Const.DETAIL_HERO_MIN_PERCENT ~ Const.DETAIL_HERO_MAX_PERCENT。
   */
  heroPercent: number = 100;
  /**
   * 「回到首图」按钮的透明度：首图满屏时为 0（不打扰），收缩后渐显到 1。
   */
  topButtonOpacity: number = 0;
  /**
   * 列表滚动控制器：回顶时用。
   */
  scrollerForList: Scroller = new Scroller();
  /**
   * 累计滚动位移（vp）：仅作记录与调试，不参与界面计算。
   */
  offsetSum: number = 0;
}
