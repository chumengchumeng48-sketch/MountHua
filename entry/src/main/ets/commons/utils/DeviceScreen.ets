/**
 * 设备信息工具类（对齐老师参考工程的 DeviceScreen）。
 *
 * 详情页的首图「滚动收缩」要用到列表的可视高度：手指滑过的位移（vp）得换算成
 * 首图高度的变化幅度，才知道这一帧该把首图压下去多少。所以这个工具类只提供
 * 一个能力 —— 拿到当前设备的可视高度（单位：vp）。
 *
 * 单位换算这一步不能省：display 模块返回的是**物理像素**，而页面布局用的是 vp，
 * 两者差一个屏幕密度比。以 160 dpi 为基准（1 vp = 1 px @160dpi），于是
 * vp = px × 160 / densityDPI。少了这一步，在 480 dpi 的机器上算出来的可视高度
 * 会是实际值的 3 倍，首图滑一下就缩没了。
 */
import display from '@ohos.display';
import Logger from './Logger';

export class DeviceScreen {
  /**
   * 当前设备可视区高度（单位：vp）。
   *
   * 取不到显示信息时返回 0：详情页里 screenHeight 为 0 会退化成「不做位移换算」的
   * 普通列表滚动（首图保持满屏不动），功能仍然可用，不会崩。
   */
  static getDeviceHeight(): number {
    try {
      const displayObject = display.getDefaultDisplaySync();
      const pixelHeight: number = displayObject.height;
      const densityDPI: number = displayObject.densityDPI;
      if (pixelHeight <= 0 || densityDPI <= 0) {
        return 0;
      }
      // 160 是 vp 定义的基准 dpi，用把物理像素换算成 vp。
      return pixelHeight * 160 / densityDPI;
    } catch (err) {
      Logger.error(`DeviceScreen.getDeviceHeight failed: ${JSON.stringify(err)}`);
      return 0;
    }
  }
}
