
export class CommonConstants {
  /**
   * 组件尺寸
   */
  static readonly SWIPER_DEFAULT_WIDTH: string = '66%';
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly IMAGE_CONTAINER_HEIGHT: string = '42%';
  static readonly FULL_SIZE: string = '100%';
  static readonly ICON_SIZE: string = '40%';
  static readonly BAR_WEIGHT: string = '25%';
  static readonly BAR_HEIGHT: string = '10%';
  static readonly CONTENT_WIDTH_PERCENT: string = '87%';
  static readonly SEARCHBAR_WIDTH: string = '91.1%'
  static readonly IMAGE_HEIGHT_MIN: string = '78%';

  /**
   * 组件定位
   */
  static readonly PERCENTAGE_78: string = '78%';
  static readonly PERCENTAGE_15: string = '15%';
  static readonly PERCENTAGE_25: string = '25%';

  /**
   * 组件常数
   */
  static readonly OPACITY: number = 0.6;
  static readonly BORDER_WIDTH: number = 0.5;
  static readonly COUNTDOWN: number = 5;

  /**
   * 时间常数
   */
  static readonly TRANSITION_DURATION: number = 600;
  static readonly DURATION: number = 1000;
  /**
   * 启动页四档时段的分界时刻（单位：从 00:00 起算的分钟数，含该分钟）。
   *
   * 08:12 起晨光、12:17 起正午、17:20 起黄昏、20:08 起夜晚；
   * 次日 00:00 ~ 08:11 仍算夜晚，延续前一晚的夜色。
   * 用分钟而非小时，是为了精确到这四分钟上（见 viewmodel/Startmodel 的时段判定）。
   */
  static readonly SPLASH_DAWN_MINUTE: number = 8 * 60 + 12;
  static readonly SPLASH_NOON_MINUTE: number = 12 * 60 + 17;
  static readonly SPLASH_DUSK_MINUTE: number = 17 * 60 + 20;
  static readonly SPLASH_NIGHT_MINUTE: number = 20 * 60 + 8;
  /**
   * 启动页停留时长，到时后自动切换到轮播图页面（单位：毫秒）。
   */
  static readonly SPLASH_DURATION: number = 3000;

  /**
   * 颜色常数
   */
  static readonly TRANSPARENT_COLOR: string = '#00ffffff';
  static readonly NAVIGATION_BAR_COLOR: string = '#00ff00';
  static readonly STATUS_BAR_CONTENT_COLOR: string = '#ffffff';
  static readonly NAVIGATION_BAR_CONTENT_COLOR: string = '#ffffff';
  static readonly THEME_COLOR: string = '#c82424';

  /**
   * 文本
   */
  static readonly APP_NAME: string = '华山夜爬';
  static readonly SPLASH_DES: string = '华 山';
  static readonly SPLASH_WELCOME: string = '自古华山一条路 · 夜爬东峰观日';
  static readonly SPLASH_INFO: string = '  版权所有© 2026 却家庭';
  static readonly INTRODUCTION_TITLE: string = '沿途站点';
  static readonly MAP_TITLE: string = '华山夜爬路线图';
  static readonly PLAN_TITLE: string = '夜爬时刻';
  static readonly GEAR_TITLE: string = '夜爬准备';

  /**
   * Default content in the search box.
   */
  static readonly PANEL_PLACEHOLDER: string = '搜索站点，如 北峰、金锁关…';
  /**
   * Number of columns.
   */
  static readonly GRID_COLUMNS: string = '1fr 1fr 1fr 1fr 1fr';
  /**
   * 面板宫格的行数：15 个站点 ÷ 5 列 = 3 行。
   */
  static readonly GRID_ROWS: string = '1fr 1fr 1fr';

  /**
   * The start time of the line 1.
   */
  static readonly LINE_ONE_START_TIME: string = "08:00";
  /**
   * The end time of the line 1.
   */
  static readonly LINE_ONE_END_TIME: string = "18:30";
  /**
   * The start time of the line 2.
   */
  static readonly LINE_TWO_START_TIME: string = "08:00";
  /**
   * The end time of the line 2.
   */
  static readonly LINE_TWO_END_TIME: string = "18:32";
  /**
   * The weekday start time of the line 3.
   */
  static readonly LINE_THREE_START_TIME: string = "08:00";
  /**
   * The weekday end time of the line 3.
   */
  static readonly LINE_THREE_END_TIME: string = "17:55";
  /**
   * The weekend start time of the line 3.
   */
  static readonly LINE_THREE_WEEKEND_START_TIME: string = "07:57";
  /**
   * The weekend end time of the line 3.
   */
  static readonly LINE_THREE_WEEKEND_END_TIME: string = "18:30";
  /**
   * Content page url.
   *
   * 预留：区域导览（Tab2）详情页。该页面尚未实现，
   * 因此不要写入 main_pages.json，否则编译会报
   * Page '.../pages/ContentPage.ets' does not exist。
   * 待页面创建后再注册路由。
   */
  static readonly CONTENT_URL: string = 'pages/ContentPage';
  /**
   * The arrow url of the train.
   */
  static readonly ARROW_URL: string = "common/images/ic_train_arrow.png";
  /**
   * The url of the train.
   */
  static readonly TRAIN_URL: string = "common/images/ic_train.png";
  /**
   * The circle url of the train.
   */
  static readonly CIRCLE_URL: string = "common/images/ic_circle.png";
  /**
   * Icon subtitle array.
   */
  static readonly ICON_SUBTITLE_ARRAY: Array<string> = ['DESIGN STYLE', 'BUILDING INFORMATION', 'GEOGRAPHIC LOCATION'];
  /**
   * Geography light.
   */
  static readonly GEOGRAPHY_LIGHT: string = 'geography_light';
  /**
   * Geography dark.
   */
  static readonly GEOGRAPHY_DARK: string = 'geography_dark';
  /**
   * Building text.
   */
  static readonly BUILDING_TEXT: string = 'building';
  /**
   * Page transition exit delay.
   */
  static readonly EXIT_DELAY: number = 100;
  /**
   * Swiper transition duration.
   */
  static readonly SWIPER_DURATION: number = 300;
  /**
   * Shared transition duration.
   */
  static readonly SHARED_DURATION: number = 800;
  /**
   * Image item shadow radius.
   */
  static readonly SHADOW_RADIUS: number = 50;
  /**
   * Double number.
   */
  static readonly DOUBLE_NUM: number = 50;
  /**
   * Max scale.
   */
  static readonly MAX_SCALE: number = 4;
  /**
   * Color scale.
   */
  static readonly COLOR_SCALE_1: number = 0.8;
  /**
   * Color scale.
   */
  static readonly COLOR_SCALE_2: number = 1.0;
  /**
   * Swiper aspect ratio.
   */
  static readonly SWIPER_ASPECT_RATIO: number = 6 / 5;
  /**
   * Constant used to convert angles to radians.
   */
  static readonly RADIAN_CONSTANT: number = Math.PI / 180.0;
  /**
   * Bottom Latitude.
   */
  static readonly SOUTH_LATITUDE: number = 22.875142;
  /**
   * Top Latitude.
   */
  static readonly NORTH_LATITUDE: number = 22.885136;
  /**
   * Left Longitude.
   */
  static readonly WEST_LONGITUDE: number = 113.882035;
  /**
   * Right Longitude.
   */
  static readonly EAST_LONGITUDE: number = 113.890274;
  /**
   * 底图像素宽度（ic_hs_map.png 的实际宽度）。
   *
   * 地图层的宽度按「底图宽高比 × 地图层高度」换算：
   * mapWidth = MAP_WIDTH * mapHeight / MAP_HEIGHT（见 controller/MapController）。
   */
  static readonly MAP_WIDTH: number = 1200;
  /**
   * 底图像素高度（ic_hs_map.png 的实际高度）。
   */
  static readonly MAP_HEIGHT: number = 1600;
  /**
   * X-axis adjustment value.
   */
  static readonly X_ADJ: number = -480;
  /**
   * Y-axis adjustment value.
   */
  static readonly Y_ADJ: number = -78;
  /**
   * Quarter circle.
   */
  static readonly QUARTER_CIRCLE: number = Math.PI / 4;
  /**
   * Operation constant.
   */
  static readonly DOUBLE_OR_HALF: number = 2;
  /**
   * Number of landmarks on the map（夜爬站点数量）。
   */
  static MAP_LANDMARKS_LENGTH: number = 15;
  /**
   * 捏合手势每一档的放大倍数。
   *
   * 模板原值是 1.1，但 1.1 的四档上限只有 1.46 倍，放大后几乎看不出变化；
   * 这里改成 1.25，四档合计 1.25^4 ≈ 2.44 倍，配合拖动才有「看细节」的意义。
   */
  static readonly MAP_ZOOM_RATIO: number = 1.25;
  /**
   * 地图只允许放大四档（配合 MAP_ZOOM_RATIO 共约 2.44 倍）。
   */
  static readonly ZOOM_MAX_TIMES: number = 4;
  /**
   * 拖动手势的最小识别距离（单位：vp），避免手指轻点就误判成拖动。
   */
  static readonly MAP_PAN_DISTANCE: number = 5;
  /**
   * 地图地标图标尺寸（单位：vp）。
   *
   * 15 个站点在屏幕上间距约 30vp，图标取 20vp 保证互不压盖。
   */
  static readonly MAP_LANDMARKS_SIZE: number = 20;
  /**
   * Scale precision of kneading gestures.
   */
  static readonly MAP_SCALE_ACCURACY: number = 2;
  /**
   * 地标名称相对「地标图标左上角」的水平偏移（单位：vp）：
   * 图标宽 20vp，取 23vp 即名称落在图标右侧 3vp 处。
   */
  static readonly MAP_TEXT_OFFSET_X: number = 23;
  /**
   * 地标名称相对「地标图标左上角」的垂直偏移（单位：vp），让文字与图标居中对齐。
   */
  static readonly MAP_TEXT_OFFSET_Y: number = 3;
  /**
   * Map Operation Finger Count.
   */
  static readonly MAP_FINGER_COUNT: number = 2;
  /**
   *  Transparency at presentation.
   */
  static readonly PANEL_HIGH_OPACITY: number = 0.8;
  /**
   * Transparency when folded.
   */
  static readonly PANEL_LOW_OPACITY: number = 0.3;
  /**
   * 折叠面板内容区展开时的高度（单位：vp）：搜索框 40 + 间距 8 + 宫格 210。
   */
  static readonly PANEL_FULL_HEIGHT: number = 258;
  /**
   * 面板顶部折叠箭头所在行的高度（单位：vp）。面板收起后这一行仍然可见，
   * 用于把面板重新拉起来，因此地图预留空间时要把它一起算上。
   */
  static readonly PANEL_ARROW_HEIGHT: number = 24;
  /**
   * 面板（箭头 + 内容区）展开时的总高度（单位：vp）。
   */
  static readonly PANEL_TOTAL_HEIGHT: number =
    CommonConstants.PANEL_FULL_HEIGHT + CommonConstants.PANEL_ARROW_HEIGHT;
  /**
   * 面板里站点宫格的高度（单位：vp）：5 列 × 3 行，单行 40 图标 + 6 边距 + 文本。
   */
  static readonly GRID_HEIGHT: number = 210;
  /**
   * 地图上选中站点浮层卡片的宽边距、高度与间距（单位：vp）。
   */
  static readonly SPOT_CARD_HEIGHT: number = 92;
  static readonly SPOT_CARD_GAP: number = 10;
  /**
   * 搜索框背景色：面板是夜底色，输入框用浅色以便看清输入内容。
   */
  static readonly PANEL_SEARCH_BG: string = '#E8EDF5';
  /**
   * Animation duration.
   */
  static readonly ANIMATION_DURATION: number = 750;
  /**
   * Normal font color opacity.
   */
  static readonly FONT_COLOR_OPACITY_NORMAL: number = 0.6;
  /**
   * 100 vp.
   */
  static readonly FULL_PERCENT_NUMBER: number = 100;
  /**
   * Image swiper cache count.
   */
  static readonly IMAGE_SWIPER_CACHE_COUNT: number = 3;
  /**
   * Animation duration normal.
   */
  static readonly ANIMATION_DURATION_NORMAL: number = 1000;
  /**
   * List position begin.
   */
  static readonly LIST_POSITION_BEGIN: number = 0;
  /**
   * List position middle.
   */
  static readonly LIST_POSITION_MIDDLE: number = 1;
  /**
   * List position end.
   */
  static readonly LIST_POSITION_END: number = 2;
  /**
   * Opacity min.
   */
  static readonly OPACITY_MIN: number = 0;
  /**
   * Opacity max.
   */
  static OPACITY_MAX: number = 1;
  /**
   * List scroll down threshold.
   */
  static readonly LIST_SCROLL_DOWN_THRESHOLD: number = -40;
  /**
   * Home icon margin top.
   */
  static readonly HOME_ICON_MARGIN_TOP: number = 80;
  /**
   * Device dpi.
   */
  static readonly DEVICE_DPI: number = 160;
  /**
   * Offset sum threshold.
   */
  static readonly OFFSET_SUM_THRESHOLD: number = 10;
  /**
   * Offset divide ratio.
   */
  static readonly OFFSET_DIVIDE_RATIO: number = 5;
  /**
   * Scroll up top threshold.
   */
  static readonly SCROLL_UP_TOP_THRESHOLD: number = -100;
  /**
   * Star icon margin.
   */
  static readonly STAR_ICON_MARGIN: number = 80;

  /**
   * Fixed item Height.
   */
  static readonly FIXED_ITEM_HEIGHT: number = 500;
  /**
   * Sticky height.
   */
  static readonly STICKY_HEIGHT: number = 229;
  /**
   * Second list item height.
   */
  static readonly SECOND_LIST_ITEM_HEIGHT: number = 350;
  /**
   * Min image height.
   */
  static readonly MIN_IMAGE_HEIGHT: number = 40;
  /**
   * Introduction image count.
   */
  static readonly INTRODUCTION_IMAGE_COUNT: number = 5;
  /**
   * Image animation duration.
   */
  static readonly IMAGE_ANIMATION_DURATION: number = 300;
  /**
   * Image divide number.
   */
  static readonly HALF_COUNT = Math.floor(CommonConstants.INTRODUCTION_IMAGE_COUNT / CommonConstants.DOUBLE_OR_HALF);
  /**
   * Image width offset.
   */
  static readonly IMAGE_WIDTH_OFFSET: number = 6.7;
  /**
   * Image x offset max.
   */
  static readonly IMAGE_X_OFFSET_MAX: number = 70;
  /**
   * Image x offset min.
   */
  static readonly IMAGE_x_OFFSET_MIN: number = 45;
  /**
   * Image opacity reduce.
   */
  static readonly IMAGE_OPACITY_REDUCE: number = 0.1;
  /**
   * Image aspect ratio.
   */
  static readonly IMAGE_ASPECT_RATIO: number = 16 / 21;
  /**
   * Image blur reduce.
   */
  static readonly IMAGE_BLUR_REDUCE: number = 10;
  /**
   * Title icon animation duration.
   */
  static readonly TITLE_ICON_ANIMATION_DURATION: number = 500;
  /**
   * The space of the train component.
   */
  static readonly TRAIN_SPACE: number = 12;
  /**
   * The aspectRatio of the train map image.
   */
  static readonly TRAIN_ASPECT_RATIO: number = 1.75;
  /**
   * The borderRadius of the train map image.
   */
  static readonly TRAIN_BORDER_RADIUS: number = 8;
  /**
   * The fontWeight of the train operation.
   */
  static readonly OPERATION_FONT_WEIGHT: number = 500;
  /**
   * The fontWeight of the train interval.
   */
  static readonly INTERVAL_FONT_WEIGHT: number = 400;
  /**
   * The padding left of the train.
   */
  static readonly TRAIN_PADDING_LEFT: number = 12;
  /**
   * The padding right of the train.
   */
  static readonly TRAIN_PADDING_RIGHT: number = 12;
  /**
   * The padding top of the train.
   */
  static readonly TRAIN_PADDING_TOP: number = 17;
  /**
   * The padding bottom of the train.
   */
  static readonly TRAIN_PADDING_BOTTOM: number = 18;
  /**
   * The aspectRatio of the canvas.
   */
  static readonly CANVAS_ASPECT_RADIO: number = 2.22;
  /**
   * The borderRadius of the canvas.
   */
  static readonly CANVAS_BORDER_RADIUS: number = 4;
  /**
   * The width of the canvas.
   */
  static readonly CANVAS_WIDTH: number = 865;
  /**
   * The height of the canvas.
   */
  static readonly CANVAS_HEIGHT: number = 494;
  /**
   * The width of the arrow.
   */
  static readonly ARROW_WIDTH: number = 28;
  /**
   * The height of the arrow.
   */
  static readonly ARROW_HEIGHT: number = 28;
  /**
   * The offset x of the arrow.
   */
  static readonly ARROW_OFFSET_X: number = 28 / 2;
  /**
   * The offset y of the arrow.
   */
  static readonly ARROW_OFFSET_Y: number = 28 / 2;
  /**
   * The width of the train.
   */
  static readonly TRAIN_WIDTH: number = 10;
  /**
   * The height of the train.
   */
  static readonly TRAIN_HEIGHT: number = 10;
  /**
   * The offset x of the train.
   */
  static readonly TRAIN_OFFSET_X: number = 5;
  /**
   * The offset y of the train.
   */
  static readonly TRAIN_OFFSET_Y: number = 5.5;
  /**
   * The width of the circle.
   */
  static readonly CIRCLE_WIDTH: number = 32;
  /**
   * The height of the circle.
   */
  static readonly CIRCLE_HEIGHT: number = 32;
  /**
   * The offset x of the circle.
   */
  static readonly CIRCLE_OFFSET_X: number = 16;
  /**
   * The offset y of the circle.
   */
  static readonly CIRCLE_OFFSET_Y: number = 16;
  /**
   * The init rotate angle of the train.
   */
  static readonly INIT_ROTATE_ANGLE: number = -115 - 90;
  /**
   * The millisecond of line 1.
   */
  static readonly LINE_ONE_TIME: number = 10 * 60 * 1000;
  /**
   * The millisecond of line 2.
   */
  static readonly LINE_TWO_TIME: number = 17 * 60 * 1000;
  /**
   * The millisecond of line 3.
   */
  static readonly LINE_THREE_TIME: number = 37 * 60 * 1000;
  /**
   * The Horizontal threshold of canvas.
   */
  static readonly HORIZONTAL_THRESHOLD: number = 20;
  /**
   * The vertical threshold of canvas.
   */
  static readonly VERTICAL_THRESHOLD: number = 10;
  /**
   * The average error of position.
   */
  static readonly AVERAGE_ERROR: number = 2;
  /**
   * The basic rotate angle of the train.
   */
  static readonly BASIC_ROTATE_ANGLE: number = -115;
  /**
   * The direction angle of the train.
   */
  static readonly DIRECTION: number = 90;
  /**
   * The PI angle of the train.
   */
  static readonly PI_ANGLE: number = 180;

  /**
   * 启动页停留 3 秒后自动跳转到的轮播图页面路由地址。
   */
  static readonly CAROUSEL_URL: string = 'pages/Carousel';
  /**
   * 启动页路由地址。
   */
  static readonly START_PAGE_URL: string = 'pages/StartPage';
  /**
   * 轮播图自动播放间隔，与启动页停留时长保持一致（单位：毫秒）。
   */
  static readonly CAROUSEL_INTERVAL: number = 3000;
  /**
   * 轮播图自动播放动画时长（单位：毫秒）。
   */
  static readonly CAROUSEL_DURATION: number = 400;
  /**
   * 选中指示点直径（单位：vp）。
   */
  static readonly DOT_ACTIVE_SIZE: number = 8;
  /**
   * 未选中指示点直径（单位：vp）。
   */
  static readonly DOT_NORMAL_SIZE: number = 6;
  /**
   * 指示点间隔（单位：vp）。
   */
  static readonly DOT_SPACE: number = 8;
  /**
   * 指示点距离屏幕底部的距离（单位：vp）。
   *
   * 不贴底，与底部保持一段留白，避免在全面屏手势条区域被遮挡。
   */
  static readonly DOT_BOTTOM_MARGIN: number = 80;
  /**
   * 轮播图顶部间距，为状态栏预留空间（单位：vp）。
   */
  static readonly CAROUSEL_TOP_MARGIN: number = 40;
  /**
   * 轮播图指示点颜色。
   */
  static readonly DOT_ACTIVE_COLOR: string = '#FFFFFF';
  /**
   * 轮播图指示点未选中颜色。
   */
  static readonly DOT_NORMAL_COLOR: string = '#99FFFFFF';
  /**
   * 启动页过渡动画时长（单位：毫秒）。
   */
  static readonly SPLASH_ANIMATION_DURATION: number = 800;

  /**
   * 主程序（3D 小镇俯视地图 + TabBar）页面路由地址。
   */
  static readonly MAIN_PAGE_URL: string = 'pages/MainPage';
  /**
   * 地图最小缩放倍数（1 = 初始铺满屏幕）。
   */
  static readonly MAP_MIN_SCALE: number = 1;
  /**
   * 地图最大缩放倍数，双指捏合放大上限。
   */
  static readonly MAP_MAX_SCALE: number = 4;
  /**
   * 地图双击缩放的目标倍数。
   */
  static readonly MAP_DOUBLE_TAP_SCALE: number = 2;
  /**
   * 模拟地图使用的底图资源（华山夜景俯视插画）。
   */
  static readonly MAP_BASE_IMAGE: Resource = $r('app.media.ic_hs_map');
  /**
   * 地图顶部标题下方的示意文案。
   */
  static readonly MAP_ATTRIBUTION: string = '华山风景名胜区 · 夜爬路线示意';
  /**
   * 地图中心定位点颜色（回中按钮中心点）。
   */
  static readonly MAP_PIN_COLOR: string = '#FF6B35';
  /**
   * 底部 TabBar 高度（单位：vp）。
   */
  static readonly TAB_BAR_HEIGHT: number = 56;
  /**
   * TabBar 图标区域尺寸（单位：vp）。
   */
  static readonly TAB_ICON_SIZE: number = 24;
  /**
   * TabBar 未选中时的图标/文字颜色（夜爬主题用浅灰蓝）。
   */
  static readonly TAB_INACTIVE_COLOR: string = '#8C9CB5';
  /**
   * TabBar 选中时的图标/文字颜色（说明书要求：选中为蓝色）。
   */
  static readonly TAB_ACTIVE_COLOR: string = '#007DFF';
  /**
   * TabBar 与内容区之间的分割线颜色。
   */
  static readonly TAB_DIVIDER_COLOR: string = '#1E2C44';
  /**
   * TabBar 背景色（夜间底栏用深蓝）。
   */
  static readonly TAB_BAR_BG_COLOR: string = '#101B2E';
  /**
   * 底部 TabBar 标题。
   */
  static readonly TAB_TITLES: Array<string> = ['路线图', '沿途站点', '夜爬时刻', '夜爬准备'];

  /**
   * 地图兜底背景色（取自底图夜空，平移留白时与底图融为一体）。
   */
  static readonly MAP_BG_COLOR: string = '#0B1626';
  /**
   * 地图定位站点动画时长（单位：毫秒）。
   */
  static readonly MAP_LOCATE_DURATION: number = 400;

  /**
   * ===== 地图页（Map + CustomPanel + PositionGrid）=====
   */
  /**
   * 地标名称颜色（夜底色上统一用白字，另加半透明深色底衬）。
   */
  static readonly MAP_TEXT_COLOR: string = '#FFFFFF';
  /**
   * 地标名称的底衬色与圆角，保证字压在底图上仍然清晰。
   */
  static readonly MAP_TEXT_BG_COLOR: string = '#B3060E1A';
  static readonly MAP_TEXT_RADIUS: number = 8;
  /**
   * 选中站点的高亮色（名称底衬与高亮圆环）。
   */
  static readonly MARKER_SELECTED_COLOR: string = '#FFC46B';
  /**
   * 面板宫格中未选中 / 选中的文字色。
   */
  static readonly PANEL_ITEM_TEXT: string = '#C9D6E6';
  static readonly PANEL_ITEM_TEXT_ACTIVE: string = '#FFC46B';
  /**
   * 底部功能区过渡动画时长（单位：毫秒）。
   */
  static readonly FUNC_AREA_ANIMATION: number = 250;
  /**
   * 地图上浮层小标签的底色（标题、进度、缩放倍数统一用这一种）。
   */
  static readonly MAP_CHIP_BG: string = 'rgba(0,0,0,0.45)';
  /**
   * 地图操作提示语（双击缩放的焦点在视口中心，所以提示里不写「点哪放哪」）。
   */
  static readonly MAP_ZOOM_HINT: string = '双指捏合缩放 · 拖动平移 · 双击放大一档';

  /**
   * ===== 夜爬路线绘制（Tab1 路线图）=====
   */
  /**
   * 路线主色（山间灯火暖黄）。
   */
  static readonly ROUTE_LINE_COLOR: string = '#FFC46B';
  /**
   * 路线内线宽度（单位：vp）。
   *
   * 地图层不再整体缩放，折线点位已经换算成「当前地图尺寸」下的坐标，
   * 所以线宽直接用 vp，屏幕上粗细恒定。
   */
  static readonly ROUTE_LINE_WIDTH: number = 3;
  /**
   * 路线外层光晕的颜色与宽度（营造灯火光带效果，单位：vp）。
   */
  static readonly ROUTE_GLOW_COLOR: string = '#4DFFA53F';
  static readonly ROUTE_GLOW_WIDTH: number = 10;
  /**
   * 路线中间点的法向摆动幅度（底图像素），让折线呈盘山走势。
   * 底图 1200 像素宽，摆幅 28 像素换算到屏幕上大约 9vp。
   */
  static readonly ROUTE_WAVE_AMP: number = 28;
  /**
   * 站点类型配色：起点 / 补给点 / 险段 / 峰顶 / 关隘。
   */
  static readonly KIND_START_COLOR: string = '#3ED07A';
  static readonly KIND_SUPPLY_COLOR: string = '#4DA3FF';
  static readonly KIND_DANGER_COLOR: string = '#FF7043';
  static readonly KIND_PEAK_COLOR: string = '#FFC46B';
  static readonly KIND_PASS_COLOR: string = '#B48CFF';
  /**
   * 夜爬全程预计用时（分钟）：21:30 出发 → 05:20 抵达东峰。
   */
  static readonly CLIMB_DURATION_MINUTES: number = 470;
  /**
   * 当前时刻 / 夜爬进度刷新周期（单位：毫秒）。
   */
  static readonly CLIMB_TICK_MS: number = 15000;
  /**
   * 进度圆点尺寸与配色（当前夜爬位置）。
   */
  static readonly PROGRESS_DOT_SIZE: number = 16;
  static readonly PROGRESS_DOT_COLOR: string = '#FFFFFF';
  static readonly PROGRESS_GLOW_COLOR: string = '#66FFC46B';

  /**
   * ===== 夜爬主题配色（内容页深色夜间底）=====
   */
  static readonly NIGHT_BG: string = '#0B1424';
  static readonly NIGHT_CARD_BG: string = '#16233A';
  static readonly NIGHT_CARD_BG_LIGHT: string = '#1E2E4A';
  static readonly NIGHT_TEXT: string = '#EAF1FA';
  static readonly NIGHT_TEXT_SUB: string = '#8FA3BE';
  static readonly NIGHT_DIVIDER: string = '#22334F';
  static readonly NIGHT_ACCENT: string = '#FFC46B';
  /**
   * 内容页通用间距。
   */
  static readonly PAGE_MARGIN: number = 14;
  static readonly CARD_RADIUS: number = 14;
  static readonly CARD_PADDING: number = 14;
  static readonly LIST_ITEM_GAP: number = 10;
  /**
   * ===== Tab2 站点卡组（环形卡组，对齐老师参考工程的 Zones 页面）=====
   * 15 张卡片排成一圈：最前面那张最大最清晰，上下各错开两层向外铺开，
   * 越往外越窄、越模糊、越淡；上下滑动（或点侧边的卡）把卡组一格一格转过去。
   *
   * 尺寸全部按「基准卡高 / 卡组宽度的百分比」表达，所以换屏幕、换字号都不会
   * 溢出；调观感只动这一段，页面里不出现任何魔法数字。
   */
  /**
   * 卡片宽度按卡组宽度的百分比：最前面那张占 DECK_AHEAD_WIDTH%，
   * 每往外一档再窄 DECK_WIDTH_STEP 个百分点。
   */
  static readonly DECK_AHEAD_WIDTH: number = 86;
  static readonly DECK_WIDTH_STEP: number = 10;
  /**
   * 环上「背面」那张卡的宽度百分比。
   *
   * 取 DECK_AHEAD_WIDTH - DECK_NEAR_RANGE × DECK_WIDTH_STEP（= 66）而不是 86，
   * 是为了让「最外一档」和「已经绕到背面」两张卡尺寸相同：卡片转过背面的
   * 那一刻宽度不跳变，动画看不出接缝。它正好被最前面那张完全盖住。
   */
  static readonly DECK_BACK_WIDTH: number = 66;
  /**
   * 上下各错排几层（环上距离超过这个值的卡退到背面叠着）。
   */
  static readonly DECK_NEAR_RANGE: number = 2;
  /**
   * 错排的纵向位移（单位：最前面那张卡的高）：±1 档 / ±2 档离中心的距离。
   *
   * 老师参考代码里这两档是写死的 100 / 180（vp）—— 注意他写的是
   * `-offsetIndex * 90`，offsetIndex 本身是 ±2，所以 ±2 档实际是 180。
   * 这里换算成卡高的比例（100/258 ≈ 0.39、180/258 ≈ 0.70），
   * 免得换个屏幕尺寸卡片就叠不上。
   */
  static readonly DECK_NEAR_SHIFT: number = 0.39;
  static readonly DECK_FAR_SHIFT: number = 0.70;
  /**
   * 卡牌宽高比（站点实景照片为 800 × 500，即 8:5）。
   */
  static readonly DECK_CARD_ASPECT: number = 1.6;
  /**
   * 按高度反算卡大小时留的余量（纵向总占用刚好等于容器高度会贴边，
   * 取整误差会把最外那张卡的边缘裁掉一两像素）。
   */
  static readonly DECK_HEIGHT_RATIO: number = 0.94;
  /**
   * 卡牌圆角、内边距、最前面那张的描边宽度（单位：vp）。
   */
  static readonly DECK_RADIUS: number = 16;
  static readonly DECK_CARD_PADDING: number = 12;
  static readonly DECK_ACTIVE_BORDER: number = 2;
  /**
   * 卡牌投影：卡与卡之间要压出层次，否则叠在一起分不出前后。
   */
  static readonly DECK_SHADOW_RADIUS: number = 18;
  static readonly DECK_SHADOW_COLOR: string = 'rgba(0,0,0,0.45)';
  static readonly DECK_SHADOW_OFFSET_Y: number = 8;
  /**
   * 每远一档的模糊半径、最大模糊半径（单位：vp）。
   */
  static readonly DECK_BLUR_STEP: number = 6;
  static readonly DECK_BLUR_MAX: number = 12;
  /**
   * 每远一档的不透明度衰减：越远越淡，纵深感才出来。
   */
  static readonly DECK_OPACITY_STEP: number = 0.12;
  /**
   * 站点序号徽标直径（单位：vp）。
   */
  static readonly DECK_BADGE_SIZE: number = 22;
  /**
   * 照片层放大比例：模糊会让边缘发虚，放大一点把虚边挤出可视区。
   */
  static readonly DECK_PHOTO_OVERSCAN: number = 1.08;
  /**
   * 卡牌底部渐变遮罩（#AARRGGBB：透明 → 夜色），保证站名与数据读得清。
   */
  static readonly DECK_GRADIENT_TOP: string = '#000B1424';
  static readonly DECK_GRADIENT_MID: string = '#590B1424';
  static readonly DECK_GRADIENT_BOTTOM: string = '#E60B1424';
  static readonly DECK_GRADIENT_ANGLE: number = 180;
  /**
   * 卡组旋转一格动画时长（毫秒）、上下滑动的切换阈值（单位：vp）。
   *
   * 阈值取 60（老师参考代码同值）：小于它的位移只让卡组跟手走一点、不切换，
   * 免得手指稍微一动就翻页。
   */
  static readonly DECK_ANIMATION: number = 320;
  static readonly DECK_SWIPE_THRESHOLD: number = 60;
  /**
   * 卡组操作提示文案。
   */
  static readonly DECK_HINT: string = '上下滑动切换站点';
  /**
   * 卡面站点简介最多显示几行（超出省略）。
   */
  static readonly DECK_INTRO_LINES: number = 2;
  /**
   * Tab3 时间轴：时间列宽度、轴线圆点直径、单行高度（单位：vp）。
   */
  static readonly TIMELINE_DOT_SIZE: number = 12;
  static readonly TIMELINE_ROW_MIN_HEIGHT: number = 62;

  /**
   * ===== 站点实景照片 =====
   * 其中 11 张（玉泉院 / 五里关 / 莎萝坪 / 毛女洞 / 回心石 / 千尺幢 / 百尺峡 /
   * 北峰 / 苍龙岭 / 金锁关 / 东峰）为用户提供的夜景素材（v2，2026-09-24 换入），
   * 其余 4 张（青柯坪 / 老君犁沟 / 擦耳崖 / 五云峰）仍来自 Wikimedia Commons。
   * 逐张来源与授权见 `.workbuddy/gen/credits.md`。
   */
  /**
   * 站点卡片里照片条的高度与圆角（单位：vp）。
   */
  static readonly SPOT_PHOTO_HEIGHT: number = 132;
  static readonly SPOT_PHOTO_RADIUS: number = 10;
  /**
   * 地图上选中站点浮层里缩略图的宽高（单位：vp）。
   */
  static readonly SPOT_THUMB_WIDTH: number = 92;
  static readonly SPOT_THUMB_HEIGHT: number = 60;
  /**
   * 照片版权说明文案（页面底部展示）。
   * 长度已按 9vp 字号 + 92% 行宽校过，插进页脚只会占一行。
   */
  static readonly SPOT_PHOTO_CREDIT: string = '照片来源：Wikimedia Commons（CC0/CC BY/CC BY-SA）与用户提供素材';
  /**
   * Tab2 数据口径说明（页面底部展示）。
   */
  static readonly ZONES_DATA_NOTE: string = '海拔、里程与时刻为示意数据，实际以华山景区公告为准。';
  /**
   * Tab2 站点所在位置的标签文案。
   */
  static readonly ZONES_CURRENT_TAG: string = '当前位置';
  /**
   * Tab2 总览卡「当前已过站点」的前缀。
   */
  static readonly ZONES_REACHED_PREFIX: string = '已过';

  /**
   * ===== 站点详情页（Tab2 卡片点进去的那一页，对齐老师参考工程的 ContentPage）=====
   * 结构：首图（随滚动收缩）→ 标题区 → 三个分区（吸顶标题切换）。
   * 所有尺寸与阈值都集中在这里，页面里不出现魔法数字。
   */
  /**
   * 路由传参的键名：详情页按站点序号取数据。
   */
  static readonly ROUTER_PARAM_ID: string = 'id';
  /**
   * 站点详情页的路由地址（必须与 main_pages.json 里注册的路径一致）。
   */
  static readonly SPOT_DETAIL_PAGE_URL: string = 'pages/SpotDetailPage';
  /**
   * 首图高度（占列表可视高度的百分比）的上下限，以及收缩过程要滑过几屏。
   *
   * 满屏（100%）→ 收缩到底（42%）需要滑过 0.30 屏：太短则一碰就缩没了，
   * 太长则首图压不下去、下面正文半天翻不出来。
   */
  static readonly DETAIL_HERO_MAX_PERCENT: number = 100;
  static readonly DETAIL_HERO_MIN_PERCENT: number = 42;
  static readonly DETAIL_HERO_SCROLL_FULL: number = 0.30;
  /**
   * 浮在首图上的圆形按钮（左上返回 / 右下回到首图）。
   */
  static readonly DETAIL_BAR_MARGIN: number = 16;
  static readonly DETAIL_BAR_SIZE: number = 38;
  static readonly DETAIL_BAR_BG: string = '#73101B2E';
  static readonly DETAIL_BAR_BORDER: string = '#33FFFFFF';
  static readonly DETAIL_BAR_ICON: number = 18;
  /**
   * 首图底部渐变遮罩（#AARRGGBB：上淡下浓）与渐变角度，保证叠在照片上的站名读得清。
   */
  static readonly DETAIL_HERO_MASK_TOP: string = '#330B1424';
  static readonly DETAIL_HERO_MASK_MID: string = '#800B1424';
  static readonly DETAIL_HERO_MASK_BOTTOM: string = '#F20B1424';
  static readonly DETAIL_HERO_MASK_ANGLE: number = 180;
  /**
   * 吸顶分区标题条：高度、图标尺寸、图标底板圆角。
   */
  static readonly DETAIL_STICKY_HEIGHT: number = 46;
  static readonly DETAIL_STICKY_ICON: number = 16;
  static readonly DETAIL_STICKY_RADIUS: number = 7;
  /**
   * 三个分区的标题（与页面里 sectionIcons 的顺序一一对应）。
   */
  static readonly DETAIL_SECTION_TITLES: Array<string> = ['站点简介', '沿途影像', '夜爬提示'];
  /**
   * 点「回到首图」时列表回滚与首图长回去的动画时长（毫秒）。
   */
  static readonly DETAIL_BACK_TOP_DURATION: number = 320;
  /**
   * 标题区三宫格与进度条的标签文案。
   */
  static readonly DETAIL_LABEL_ALTITUDE: string = '海拔';
  static readonly DETAIL_LABEL_DISTANCE: string = '累计里程';
  static readonly DETAIL_LABEL_ASCENT: string = '距上一点';
  static readonly DETAIL_LABEL_PROGRESS: string = '全程进度';
  static readonly DETAIL_UNIT_ALTITUDE: string = ' m';
  static readonly DETAIL_UNIT_DISTANCE: string = ' km';
  static readonly DETAIL_UNIT_ASCENT: string = ' m';
  /**
   * 详情页的操作提示文案。
   *
   * 前两条是给 Tab2 卡片用的（卡面右下角的入口提示）与影像卡组的操作说明；
   * 「返回」「回到首图」两个按钮只画图标不写文字，所以没有对应文案常量。
   */
  static readonly DETAIL_ENTER_HINT: string = '查看详情 ›';
  static readonly DETAIL_DECK_HINT: string = '左右滑动查看前后站影像';
  static readonly DETAIL_PREVIEW_CLOSE: string = '点击任意处关闭';
  /**
   * 「沿途影像」横向卡组的参数。
   *
   * 与 Tab2 的环形卡组同一套思路：当前那张最大，两侧按环上距离错开，
   * 只是这里只横向排（左 / 右各最多两级），并且不做模糊 —— 影像要看清。
   */
  static readonly DETAIL_DECK_CARD_ASPECT: number = 1.6;
  /**
   * 当前那张卡宽度占卡组宽度的百分比、每远一档再窄几个百分点。
   *
   * 卡面宽度跟位移是一起定的，改一组必须一起复核。校验式（都以卡组宽度为 1）：
   *   某档外沿 = 该档位移 + 该档宽度 / 2，不能超过 0.5（否则被裁边）；
   *   某档露出的边 = 该档外沿 − 前一档外沿，太小就等于看不见。
   * 按现在的取值：
   *   前卡 外沿 0.29
   *   ±1 档 位移 0.20 + 半宽 0.24 = 外沿 0.44 → 露出 0.15
   *   ±2 档 位移 0.30 + 半宽 0.19 = 外沿 0.49 → 露出 0.05（只是个「还能翻」的暗示）
   * 五张卡都在卡组宽度内，不裁边；前卡独占中间近六成，主次清楚。
   */
  static readonly DETAIL_DECK_AHEAD_WIDTH: number = 58;
  static readonly DETAIL_DECK_WIDTH_STEP: number = 10;
  /**
   * 横向位移（占卡组宽度的百分比）：±1 档 / ±2 档离中心多远。
   *
   * 老师参考代码写的是固定 vp（−70 / −45），换个屏宽就挤到一块儿去了；
   * 这里按卡组宽度的百分比给，位移跟着卡组一起缩放。
   */
  static readonly DETAIL_DECK_NEAR_SHIFT: number = 20;
  static readonly DETAIL_DECK_FAR_SHIFT: number = 30;
  /**
   * 环上距离超过这个档位的卡退出可视区（淡出叠到后面）。
   *
   * 卡组一共 5 张（前 2 + 本站 + 后 2），从中间进来看 5 张都在；
   * 滑到最边上时最外那两张才退到后面。
   */
  static readonly DETAIL_DECK_NEAR_RANGE: number = 2;
  static readonly DETAIL_DECK_ANIMATION: number = 300;
  /**
   * 横滑判定的位移阈值（vp）：小手抖不算切换。
   */
  static readonly DETAIL_DECK_SWIPE_THRESHOLD: number = 30;
  /**
   * 卡下方「站名 + 序号」标注区的高度（vp）：卡组容器高度 = 前卡高度 + 它。
   */
  static readonly DETAIL_DECK_TEXT_BLOCK: number = 40;
  /**
   * 「沿途影像」卡组里，本站前后各取几个邻站的照片。
   *
   * 取 2 表示列表共 5 张（前 2 + 本站 + 后 2）：横向滑两下就能看到前后站的实景，
   * 再多就滑不到头了；遇到首尾则按环上顺序回绕。
   */
  static readonly DETAIL_PHOTO_NEIGHBOR_RADIUS: number = 2;
  /**
   * 分区之间的竖向留白、分区正文宽度（占屏宽百分比）。
   */
  static readonly DETAIL_SECTION_GAP: number = 22;
  static readonly DETAIL_BODY_WIDTH: string = '92%';
  /**
   * 首图底部渐变遮罩的高度（vp）与全程进度条高度（vp）。
   */
  static readonly DETAIL_HERO_MASK_HEIGHT: number = 220;
  static readonly DETAIL_PROGRESS_BAR_HEIGHT: number = 6;
  /**
   * 点当前影像弹出的全屏大图预览底板色。
   */
  static readonly DETAIL_PREVIEW_BG: string = '#F20B1424';
}

/**
 * Train route.
 */
export enum TrainsLine {
  LINE_ONE = 0,
  LINE_TWO = 1,
  LINE_THREE = 2,
}


/**
 * Landmark type.
 */
export enum PositionType {
  TRAIN_STATION = 1, //火车站
  MOTHER_CHILD_ROOM = 2, //母婴房
  CAR_ROAD = 3, //车行道
  CAFE = 4, //咖啡厅
  SMOKING_AREA = 5, //吸烟区
  CONVENIENCE_STORE = 6, //便利店
  GYMNASIUM = 7, //健身房
  RESTAURANT = 8, //餐厅
  SIDE_WALK = 9, //人行道
  LIBRARY = 10 //图书馆
}