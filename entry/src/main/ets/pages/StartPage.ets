import { router } from '@kit.ArkUI';
import Logger from '../commons/utils/Logger';
import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import { currentStartPhase, clockText, IStartPhase, startPhases, StartPhase } from '../viewmodel/Startmodel';

/**
 * 启动页面。
 *
 * 流程：
 * 1. 先展示欢迎界面（按时段变化的渐变背景 + 山形 logo + 标语），
 *    停留 3 秒（Const.SPLASH_DURATION）；
 * 2. showSwiper 置为 true，就地切换为轮播图：
 *    - 按当前时刻自动选图（四档：晨光 / 正午 / 黄昏 / 夜晚，见 viewmodel/Startmodel）；
 *    - 自动轮播 + 循环 + 支持手动滑动，左上角显示当前时段与时刻，右上角显示「跳过 N」倒计时；
 * 3. 倒计时结束（Const.COUNTDOWN）或用户点击跳过 → 进入主程序（pages/MainPage）。
 *
 * 时段分界：08:12 / 12:17 / 17:20 / 20:08（常量见 CommonConstants.SPLASH_*_MINUTE）。
 * 00:00 ~ 08:11 归夜晚档，延续前一晚的夜色。
 */
@Entry
@Component
struct StartPage {
  /**
   * 轮播控制器。
   */
  private swiperController: SwiperController = new SwiperController();
  /**
   * 当前时段档位（名称 / 提示 / 图组 / 欢迎页背景）。
   */
  private phase: IStartPhase = startPhases[StartPhase.NIGHT];
  /**
   * 当前时段的轮播图集合。
   */
  private data: Resource[] = [];
  /**
   * 倒计时定时器句柄。
   */
  private timer: number = 0;
  /**
   * 轮播页倒计时（秒），倒计时结束自动进入主程序。
   */
  @State countdown: number = Const.COUNTDOWN;
  /**
   * false = 欢迎界面；true = 时段轮播图。
   */
  @State showSwiper: boolean = false;
  /**
   * 轮播当前索引，驱动底部指示点。
   */
  @State currentIndex: number = 0;
  /**
   * 当前时刻文案（HH:mm）与时段名，显示在启动页角标上。
   */
  @State nowText: string = '';
  @State phaseName: string = '';
  @State phaseHint: string = '';
  /**
   * 当前时段对应的欢迎页渐变背景。
   */
  @State phaseBg: Resource = $r('app.media.splash_bg_night');

  aboutToAppear(): void {
    // 按当前时刻（精确到分）挑时段：08:12 晨光 / 12:17 正午 / 17:20 黄昏 / 20:08 夜晚。
    const now = new Date();
    this.phase = currentStartPhase(now);
    this.data = this.phase.images;
    this.nowText = clockText(now);
    this.phaseName = this.phase.name;
    this.phaseHint = this.phase.hint;
    this.phaseBg = this.phase.bg;
    Logger.info(`StartPage phase: ${this.phaseName} at ${this.nowText}`);

    // 欢迎界面停留 3 秒后切换为轮播图，并开始倒计时。
    setTimeout(() => {
      this.showSwiper = true;
      this.startTiming();
    }, Const.SPLASH_DURATION);
  }

  aboutToDisappear(): void {
    this.clearTiming();
  }

  /**
   * 开始倒计时：每秒递减，归零后进入主程序。
   */
  startTiming(): void {
    this.timer = setInterval(() => {
      if (this.countdown === 0) {
        this.clearTiming();
        this.jumpToMainPage();
        return;
      }
      this.countdown--;
      Logger.info(`StartPage countdown: ${this.countdown}`);
    }, Const.DURATION);
  }

  /**
   * 清理倒计时定时器。
   */
  clearTiming(): void {
    clearInterval(this.timer);
  }

  /**
   * 进入主程序。
   *
   * 使用 replaceUrl：启动流程不保留在路由栈中，主程序按返回键不会退回启动页。
   */
  jumpToMainPage(): void {
    router.replaceUrl({ url: Const.MAIN_PAGE_URL })
      .then(() => {
        Logger.info('Succeeded in jumping to main page.');
      })
      .catch((err: Error) => {
        Logger.error(`Failed to jump to main page. Cause: ${JSON.stringify(err)}`);
      });
  }

  build() {
    Stack() {
      if (this.showSwiper) {
        // ===== 阶段二：时段轮播图 + 倒计时跳过 =====
        // Swiper 直接作为根 Stack 的子节点，铺满全屏。
        Swiper(this.swiperController) {
          ForEach(this.data, (item: Resource, index: number) => {
            Image(item)
              .width(Const.FULL_PERCENT)
              .height(Const.FULL_SIZE)
              .objectFit(ImageFit.Cover)
              .draggable(false)
          }, (item: Resource, index: number) => index.toString())
        }
        .autoPlay(true)
        .interval(Const.CAROUSEL_INTERVAL)
        .duration(Const.CAROUSEL_DURATION)
        .loop(true)
        .indicator(false)
        .disableSwipe(false)
        .curve(Curve.EaseInOut)
        .cachedCount(1)
        .index(0)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .width(Const.FULL_PERCENT)
        .height(Const.FULL_SIZE)

        // 全屏透明浮层：时段角标贴左上、跳过按钮贴右上、提示语与指示点贴底。
        // hitTestBehavior(Transparent) 让空白区域的触摸穿透到下面的 Swiper，
        // 不影响左右滑动；按钮和圆点自身仍可点击。
        Column() {
          Row() {
            // 左上角角标：当前时段 + 当前时刻，用来对照「此刻该是哪一档图」。
            Column({ space: 2 }) {
              Text(this.phaseName)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .textShadow({ radius: 6, color: '#A6000000', offsetX: 0, offsetY: 1 })
              Text(this.nowText)
                .fontSize(11)
                .fontColor(Color.White)
                .opacity(0.9)
                .textShadow({ radius: 6, color: '#A6000000', offsetX: 0, offsetY: 1 })
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .backgroundColor($r('app.color.swiper_jump_bg_color'))
            .borderRadius(14)

            Text(`跳过 ${this.countdown}`)
              .fontSize(14)
              .fontColor(Color.White)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor($r('app.color.swiper_jump_bg_color'))
              .borderRadius(16)
              .onClick(() => {
                this.clearTiming();
                this.jumpToMainPage();
              })
          }
          .width(Const.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ top: Const.CAROUSEL_TOP_MARGIN, left: 16, right: 16 })

          Blank()

          // 时段提示语，切换时段时会跟着换。
          Text(this.phaseHint)
            .fontSize(14)
            .fontColor(Color.White)
            .opacity(0.95)
            .letterSpacing(2)
            .textShadow({ radius: 8, color: '#B3000000', offsetX: 0, offsetY: 1 })
            .margin({ bottom: 14 })

          this.buildIndicator()
        }
        .width(Const.FULL_PERCENT)
        .height(Const.FULL_SIZE)
        .hitTestBehavior(HitTestMode.Transparent)
      } else {
        // ===== 阶段一：欢迎界面 =====
        Stack() {
          // 按时段变化的渐变背景（晨光/正午/黄昏/夜晚四档，见 viewmodel/Startmodel）。
          Image(this.phaseBg)
            .width(Const.FULL_PERCENT)
            .height(Const.FULL_SIZE)
            .objectFit(ImageFit.Cover)

          Column() {
            // 白色山形 logo（三峰 + 蜿蜒山道）。
            Image($r('app.media.ic_hs_logo'))
              .width(104)
              .margin({ top: 200 })

            // 标题与副标题。
            Text(Const.SPLASH_DES)
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .letterSpacing(6)
              .textShadow({ radius: 10, color: '#99000000', offsetX: 0, offsetY: 2 })
              .margin({ top: 16 })

            // 暖色装饰短线，呼应底图中的山间灯火。
            Row()
              .width(56)
              .height(2)
              .backgroundColor(Const.NIGHT_ACCENT)
              .margin({ top: 16, bottom: 16 })

            Text(Const.SPLASH_WELCOME)
              .fontSize(14)
              .fontColor(Color.White)
              .textShadow({ radius: 8, color: '#8C000000', offsetX: 0, offsetY: 1 })

            Text('玉泉院 → 东峰观日台 · 15 站 · 全程 15.3 km')
              .fontSize(12)
              .fontColor(Color.White)
              .opacity(0.85)
              .textShadow({ radius: 8, color: '#8C000000', offsetX: 0, offsetY: 1 })
              .margin({ top: 10 })

            // 当前时段角标：让「此刻为什么是这组图」一目了然（也方便自测四个时段）。
            Text(`此刻 ${this.nowText} · ${this.phaseName}`)
              .fontSize(12)
              .fontColor(Color.White)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor($r('app.color.swiper_jump_bg_color'))
              .borderRadius(14)
              .margin({ top: 16 })

            // 弹性空白，把版权信息推到底部。
            Blank()

            Text(Const.SPLASH_INFO)
              .fontSize(12)
              .fontColor(Color.White)
              .opacity(0.9)
              .textShadow({ radius: 8, color: '#8C000000', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 90 })
          }
          .width(Const.FULL_PERCENT)
          .height(Const.FULL_SIZE)
          .alignItems(HorizontalAlign.Center)
        }
        .width(Const.FULL_PERCENT)
        .height(Const.FULL_SIZE)
      }
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_SIZE)
    .backgroundColor(Color.Black)
  }

  /**
   * 轮播图底部自定义指示点（不贴底）。
   */
  @Builder
  buildIndicator() {
    Row({ space: Const.DOT_SPACE }) {
      ForEach(this.data, (item: Resource, index: number) => {
        Circle()
          .width(index === this.currentIndex ? Const.DOT_ACTIVE_SIZE : Const.DOT_NORMAL_SIZE)
          .height(index === this.currentIndex ? Const.DOT_ACTIVE_SIZE : Const.DOT_NORMAL_SIZE)
          .fill(index === this.currentIndex ? Const.DOT_ACTIVE_COLOR : Const.DOT_NORMAL_COLOR)
          .animation({ duration: Const.CAROUSEL_DURATION, curve: Curve.EaseInOut })
          .onClick(() => {
            this.swiperController.changeIndex(index, true);
          })
      }, (item: Resource, index: number) => index.toString())
    }
    .justifyContent(FlexAlign.Center)
    .width(Const.FULL_PERCENT)
    .margin({ bottom: Const.DOT_BOTTOM_MARGIN })
  }
}
