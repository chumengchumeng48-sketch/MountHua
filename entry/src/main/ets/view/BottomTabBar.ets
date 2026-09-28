import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import { BottomTabslist } from '../viewmodel/BottomTabsModel';

/**
 * 底部导航栏（TabBar）组件。
 *
 * 单独抽成一个组件，只负责「画导航栏」这一件事：
 * 图标（选中态高亮切图 / 常态深灰切图）+ 标题文字（选中蓝色）。
 * 夜爬主题下底栏用深蓝色（Const.TAB_BAR_BG_COLOR），与地图、内容页的夜色统一。
 *
 * 当前选中项由父组件通过 selectedIndex 传入，点击某一项时通过
 * onTabSelect 回调把下标抛给父组件，由父组件（MainPage）统一控制
 * 页面切换 —— 组件自身不持有页面状态。
 */
@Component
export struct BottomTabBar {
  /**
   * 当前选中的 Tab 下标（由父组件传入）。
   */
  @Prop selectedIndex: number = 0;
  /**
   * 点击某一项的回调，参数为被点击的 Tab 下标。
   */
  onTabSelect: (index: number) => void = () => {
  };

  /**
   * 单项的图标 / 文字颜色：选中为蓝色，未选中为灰色。
   */
  private tabColor(index: number): string {
    return this.selectedIndex === index ? Const.TAB_ACTIVE_COLOR : Const.TAB_INACTIVE_COLOR;
  }

  /**
   * 单个 Tab 项：图标在上、标题在下，整项可点击。
   */
  @Builder
  buildTabItem(index: number) {
    Column({ space: 3 }) {
      this.buildTabIcon(index)
      Text(Const.TAB_TITLES[index])
        .fontSize(10)
        .fontColor(this.tabColor(index))
    }
    .width(Const.FULL_PERCENT)
    .height(Const.TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onTabSelect(index);
    })
  }

  /**
   * Tab 图标：设计切图（ic_home / ic_find / ic_drive / ic_user），
   * 选中时切换为对应的高亮切图（*_selected）。
   */
  @Builder
  buildTabIcon(index: number) {
    Image(this.selectedIndex === index
      ? BottomTabslist[index].inconSelected
      : BottomTabslist[index].icon)
      .width(Const.TAB_ICON_SIZE)
      .height(Const.TAB_ICON_SIZE)
  }

  build() {
    Row() {
      ForEach(Const.TAB_TITLES, (title: string, index: number) => {
        Column() {
          this.buildTabItem(index)
        }
        .layoutWeight(1)
      }, (title: string) => title)
    }
    .width(Const.FULL_PERCENT)
    .height(Const.TAB_BAR_HEIGHT)
    .backgroundColor(Const.TAB_BAR_BG_COLOR)
    // 导航栏与内容区之间的分割线。
    .border({ width: { top: 1 }, color: Const.TAB_DIVIDER_COLOR })
  }
}
