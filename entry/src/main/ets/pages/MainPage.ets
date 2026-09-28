import Logger from '../commons/utils/Logger';
import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import { BottomTabBar } from '../view/BottomTabBar';
import { Map } from '../view/Map';
import { ZonesView } from '../view/ZonesView';
import { PlanView } from '../view/PlanView';
import { MineView } from '../view/MineView';

/**
 * 主程序页面（外壳）。
 *
 * 本文件只做一件事：把「四个 Tab 页面」和「底部导航栏」组装起来，
 * 并维护当前选中的 Tab 下标。各页面的具体实现见 view/ 目录：
 * - view/Map.ets           Tab1 路线图（华山夜景底图 + 夜爬路线 + 15 个地标 +
 *                          可折叠的搜索面板 CustomPanel）
 * - view/ZonesView.ets     Tab2 沿途站点（15 个站点的卡片列表）
 * - view/PlanView.ets      Tab3 夜爬时刻（竖向时间轴 + 东峰观日信息）
 * - view/MineView.ets      Tab4 夜爬准备（装备清单 + 安全须知）
 * - view/BottomTabBar.ets  底部导航栏（图标 + 标题）
 *
 * 这里用自绘导航栏 + 内容区，而不是 Tabs 的 tabBar：
 * 导航栏是独立组件，页面的显示/隐藏完全由 currentTabIndex 控制，
 * 各页面之间互不干扰。
 */
@Entry
@Component
struct MainPage {
  /**
   * 当前选中的 Tab 索引。
   *
   * 注意：不能命名为 tabIndex —— 该名字与 ArkUI CustomComponent 的内置属性冲突
   * （内置签名是 (index: number) => CommonAttribute），会报
   * Property 'tabIndex' is not assignable to the same property in base type。
   */
  @State currentTabIndex: number = 0;

  build() {
    Column() {
      // 内容区：按当前下标显示对应页面（各页面各自一个文件）。
      Stack() {
        if (this.currentTabIndex === 0) {
          Map()
        } else if (this.currentTabIndex === 1) {
          ZonesView()
        } else if (this.currentTabIndex === 2) {
          PlanView()
        } else {
          MineView()
        }
      }
      .width(Const.FULL_PERCENT)
      .layoutWeight(1)

      // 底部导航栏：单独组件，点击回调切换下标。
      BottomTabBar({
        selectedIndex: this.currentTabIndex,
        onTabSelect: (index: number) => {
          this.currentTabIndex = index;
          Logger.info(`MainPage tab changed, index: ${index}`);
        }
      })
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .backgroundColor(Const.NIGHT_BG)
  }
}
