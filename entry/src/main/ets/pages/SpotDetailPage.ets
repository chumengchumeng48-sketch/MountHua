import { CommonConstants as Const } from '../commons/constants/CommonConstants';
import Logger from '../commons/utils/Logger';
import { DeviceScreen } from '../commons/utils/DeviceScreen';
import { ScrollAnimation } from '../commons/utils/ScrollAnimation';
import zonesViewModel from '../viewmodel/ZonesViewModel';
import ZonesItem from '../viewmodel/ZonesItem';
import { AnimationItem } from '../viewmodel/AnimationItem';
import { SpotPhotoDeck } from '../view/SpotPhotoDeck';

/**
 * 首图底部渐变遮罩的颜色带（透明 → 夜色）。
 *
 * 与 Tab2 卡面一样，单独写成带元组类型的常量再交给 linearGradient：
 * ArkTS 对字面量数组的类型推断比 TS 严，显式声明 Array<[ResourceColor, number]>
 * 可以避免 "not assignable" 的编译错误。
 */
const HERO_MASK_COLORS: Array<[ResourceColor, number]> = [
  [Const.DETAIL_HERO_MASK_TOP, 0.0],
  [Const.DETAIL_HERO_MASK_MID, 0.55],
  [Const.DETAIL_HERO_MASK_BOTTOM, 1.0]
];

/**
 * onScrollFrameBegin 的返回值类型。
 *
 * 自己声明一个 interface 而不是直接返回字面量，是为了满足 ArkTS
 * 「对象字面量必须有明确类型」的约束。
 */
interface ScrollFrameResult {
  offsetRemain: number;
}

/**
 * 站点详情页（Tab2 卡片点进来的那一页，对应老师参考工程的 ContentPage）。
 *
 * 页面结构（一个 List 从上往下）：
 *   0. 首图 —— 本站实景大图，随滚动收缩（100% → 42% 屏高），叠加站名 / 类型 / 时刻；
 *   1. 标题区 —— 海拔 / 累计里程 / 距上一点三宫格 + 全程进度条；
 *   2~4. 三个分区（站点简介 / 沿途影像 / 夜爬提示），**每段各带一条吸顶标题条**。
 *
 * 两个滚动联动，与老师参考工程对应：
 *   - 首图收缩：List.onScrollFrameBegin → ScrollAnimation.controlHeroScale，
 *     把列表的滑动位移先分给首图，首图到底后剩下的才让列表滚；
 *   - 「回到首图」按钮透明度：跟首图收缩比例联动，首图满屏时不打扰。
 * 吸顶标题的「换内容」不靠代码判断：三段各自是一个 ListItemGroup，
 * 谁的区段在可视区里，顶上显示的就是谁的标题条（见 build() 里的注释）。
 *
 * 与老师参考工程的三处有意差异：
 *   1. 主题是深色夜景（老师那页是浅色 #F1F3F5 + 黑字），与地图、Tab2 卡组统一；
 *   2. 分区标题换成华山口径（站点简介 / 沿途影像 / 夜爬提示），不是
 *      DESIGN STYLE / BUILDING INFORMATION / GEOGRAPHIC LOCATION；
 *   3. 没有搬老师的 ImageViewComponent（双指缩放看大图）—— 本项目一站一图，
 *      点当前影像弹出的是全屏大图预览（点任意处关闭），不做缩放与拖动。
 *
 * @version 1.0
 */
@Entry
@Component
struct SpotDetailPage {
  /**
   * 当前展示的站点（由路由传参的 id 决定，取不到就回落到第一站）。
   */
  @State contentData: ZonesItem = zonesViewModel.getZonesByIndex(0);
  /**
   * 滚动联动状态（首图高度 / 吸顶分区 / 按钮透明度 / 列表控制器）。
   */
  @State anim: AnimationItem = new AnimationItem();
  /**
   * 是否正在看大图预览。
   */
  @State showPreview: boolean = false;
  /**
   * 预览的是第几张（photoList 的下标）。
   */
  @State previewIndex: number = 0;

  /**
   * 三个分区的图标（顺序与 Const.DETAIL_SECTION_TITLES 一一对应）。
   */
  private readonly sectionIcons: Resource[] = [
    $r('app.media.ic_hs_sec_intro'),
    $r('app.media.ic_hs_sec_photo'),
    $r('app.media.ic_hs_sec_tip')
  ];

  aboutToAppear(): void {
    // 路由传参：拿站点序号去数据层取站点。传参来自页面外，可能是越界值甚至 NaN，
    // 所以整段包在 try/catch 里，取不到就显示第一站 —— 详情页不能白屏。
    try {
      // 路由参数只传了一个数字（站点序号），所以直接按数字表取，
      // 省掉一次 Object → number 的二次断言。
      // 用 `this.getUIContext().getRouter()` 而非全局 `@ohos.router`（后者自 API 18 废弃）。
      const params = this.getUIContext().getRouter().getParams() as Record<string, number>;
      const id: number = params[Const.ROUTER_PARAM_ID];
      this.contentData = zonesViewModel.getZoneById(id);
      this.previewIndex = this.contentData.photoFocusIndex;
    } catch (err) {
      Logger.error(`SpotDetailPage read router params failed: ${JSON.stringify(err)}`);
      this.contentData = zonesViewModel.getZonesByIndex(0);
    }
    // 首图高度按屏高的百分比表达，所以一开始就得知道屏高（列表量到尺寸后还会校正）。
    this.anim.screenHeight = DeviceScreen.getDeviceHeight();
    this.anim.heroPercent = Const.DETAIL_HERO_MAX_PERCENT;
  }

  /**
   * 首图高度（vp）。
   *
   * 这里给的是**绝对高度**而不是百分比：ListItem 的高度用百分比表达时，
   * 在 List 里的解析基准并不直观，而屏高我们已经有了，直接乘出来最稳。
   * 万一屏高没取到（DeviceScreen 失败且还没量到尺寸），退化成占满列表可视区，
   * 至少不会出现「首图高度 0、整页从正文开始」的破相。
   */
  private heroHeight(): Length {
    if (this.anim.screenHeight <= 0) {
      return Const.FULL_PERCENT;
    }
    return this.anim.screenHeight * this.anim.heroPercent / Const.FULL_PERCENT_NUMBER;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      List({ scroller: this.anim.scrollerForList }) {
        // ① 首图：本站实景 + 站名叠加，随滚动收缩。
        ListItem() {
          this.buildHero()
        }
        .height(this.heroHeight())

        // ② 标题区：三个关键数字 + 全程进度。
        ListItem() {
          this.buildTitleBlock()
        }

        // ③~⑤ 三个分区：每个分区各自一个 ListItemGroup + 自己的吸顶标题条。
        //
        // 为什么不是一个 group 装三段、让标题条跟着滚动换内容：
        // 那样得靠 List.onScrollIndex 判断「现在滚到第几段」，而这个下标是按
        // 「顶层 ListItem」数还是把 group 里的子项也展开数，口径并不直观 ——
        // 老师参考代码其实是绕开了它，改用写死的 500 / 1000 / 1500 滚动位移来判断。
        // 三段各带自己的 header，吸顶条越过分区边界时自然换成下一段的图标与标题，
        // 观感一样，但不依赖任何下标口径。
        ListItemGroup({ header: this.buildStickyBar(0) }) {
          ListItem() {
            this.buildIntroSection()
          }
        }
        ListItemGroup({ header: this.buildStickyBar(1) }) {
          ListItem() {
            this.buildPhotoSection()
          }
        }
        ListItemGroup({ header: this.buildStickyBar(2) }) {
          ListItem() {
            this.buildTipSection()
          }
        }
      }
      .width(Const.FULL_PERCENT)
      .height(Const.FULL_PERCENT)
      .scrollBar(BarState.Off)
      // 用 Spring 而不是 None：首图收缩到底、列表也回到顶部后，
      // 还要靠「继续往下拉」把首图拉回满屏 —— None 在顶部会直接吃掉这次拖动，
      // 首图就再也长不回去了（只能靠右下角那个按钮复位）。
      .edgeEffect(EdgeEffect.Spring)
      .sticky(StickyStyle.Header)
      .cachedCount(1)
      .onAreaChange((oldVal: Area, newVal: Area) => {
        // 列表可视高度就是首图百分比的基准，量到真实值后覆盖初值，
        // 折叠屏展开 / 分屏时也跟着更新。
        const height: number = Number(newVal.height);
        if (height > 0) {
          this.anim.screenHeight = height;
        }
      })
      .onScrollFrameBegin((offset: number) => {
        // 首图先收缩 / 先长回来，剩下的位移才交给列表滚 —— 观感是
        // 「把首图推上去、正文跟着出来」，而不是整页一起冲。
        const remain: number = ScrollAnimation.controlHeroScale(this.anim, offset);
        this.anim.offsetSum = this.anim.offsetSum + (offset - remain);
        const result: ScrollFrameResult = { offsetRemain: remain };
        return result;
      })

      // 浮动按钮：左上返回、右下回到首图。
      this.buildFloatButtons()

      // 全屏大图预览（点当前影像时弹出）。
      if (this.showPreview) {
        this.buildPreview()
      }
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .backgroundColor(Const.NIGHT_BG)
  }

  /**
   * 页面转场：从底部滑入 / 滑出（对齐老师参考工程的 pageTransition）。
   *
   * 详情页是从卡片「推进去」的，用上下滑动比默认的平移更贴合层级关系。
   */
  pageTransition() {
    PageTransitionEnter({ duration: Const.DETAIL_BACK_TOP_DURATION, curve: Curve.EaseOut })
      .slide(SlideEffect.Bottom)
    PageTransitionExit({ duration: Const.DETAIL_BACK_TOP_DURATION, curve: Curve.EaseIn })
      .slide(SlideEffect.Bottom)
  }

  /**
   * 首图：整屏实景 + 底部渐变 + 站名信息。
   */
  @Builder
  buildHero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.contentData.photo)
        .width(Const.FULL_PERCENT)
        .height(Const.FULL_PERCENT)
        .objectFit(ImageFit.Cover)
        .interpolation(ImageInterpolation.Medium)
        .draggable(false)

      // 底部渐变遮罩：把照片压暗，白色站名才读得清。
      Column()
        .width(Const.FULL_PERCENT)
        .height(Const.DETAIL_HERO_MASK_HEIGHT)
        .linearGradient({
          angle: Const.DETAIL_HERO_MASK_ANGLE,
          colors: HERO_MASK_COLORS
        })

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text(this.contentData.subTitle)
            .fontSize(11)
            .fontColor(this.contentData.backgroundColor)
            .border({ width: 1, color: this.contentData.backgroundColor })
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)

          Text(this.buildHeroMeta())
            .fontSize(12)
            .fontColor('#C2CEE0')

          Blank()

          Text(this.contentData.arriveTime)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Const.NIGHT_ACCENT)
        }
        .width(Const.FULL_PERCENT)

        Text(this.contentData.title)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(Const.FULL_PERCENT)
      }
      .width(Const.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: Const.PAGE_MARGIN,
        right: Const.PAGE_MARGIN,
        bottom: Const.DETAIL_SECTION_GAP
      })
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
  }

  /**
   * 标题区：海拔 / 累计里程 / 距上一点三个数字 + 全程进度条。
   */
  @Builder
  buildTitleBlock() {
    Column({ space: 16 }) {
      Row() {
        this.buildStatCell(Const.DETAIL_LABEL_ALTITUDE,
          `${this.contentData.altitude}${Const.DETAIL_UNIT_ALTITUDE}`,
          this.contentData.backgroundColor)
        this.buildStatCell(Const.DETAIL_LABEL_DISTANCE,
          `${this.contentData.distance}${Const.DETAIL_UNIT_DISTANCE}`,
          Const.NIGHT_TEXT)
        this.buildStatCell(Const.DETAIL_LABEL_ASCENT,
          `+${this.contentData.ascent}${Const.DETAIL_UNIT_ASCENT}`,
          Const.NIGHT_TEXT)
      }
      .width(Const.FULL_PERCENT)

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text(Const.DETAIL_LABEL_PROGRESS)
            .fontSize(12)
            .fontColor(Const.NIGHT_TEXT_SUB)
          Blank()
          Text(`${Math.round(this.contentData.progress * Const.FULL_PERCENT_NUMBER)}%`)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Const.NIGHT_ACCENT)
        }
        .width(Const.FULL_PERCENT)

        // 进度条：底槽 + 按进度撑开的填充条。最前面几站进度接近 0，
        // 给填充条留一点最小宽度，否则看起来像没画出来。
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width(Const.FULL_PERCENT)
            .height(Const.DETAIL_PROGRESS_BAR_HEIGHT)
            .borderRadius(Const.DETAIL_PROGRESS_BAR_HEIGHT / Const.DOUBLE_OR_HALF)
            .backgroundColor(Const.NIGHT_DIVIDER)
          Row()
            .width(this.progressWidth())
            .height(Const.DETAIL_PROGRESS_BAR_HEIGHT)
            .borderRadius(Const.DETAIL_PROGRESS_BAR_HEIGHT / Const.DOUBLE_OR_HALF)
            .backgroundColor(this.contentData.backgroundColor)
        }
        .width(Const.FULL_PERCENT)
      }
      .width(Const.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: Const.PAGE_MARGIN,
      right: Const.PAGE_MARGIN,
      top: Const.DETAIL_SECTION_GAP,
      bottom: Const.DETAIL_SECTION_GAP
    })
  }

  /**
   * 三宫格里的一个数字格。
   */
  @Builder
  buildStatCell(label: string, value: string, valueColor: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(valueColor)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(label)
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 吸顶分区标题条：本分区的图标 + 标题 + 「第几个 / 共几个」。
   *
   * 下标由各分区的 ListItemGroup 直接传进来（谁的头就是谁的），
   * 不去读「当前滚动到第几段」这类需要猜下标的运行时状态。
   *
   * 老师参考工程在这一条上并排画了三个图标、靠缩放数组切换显隐；这里只画
   * 当前分区那一个。原因：scale / opacity 都不改变布局，并排的三个图标
   * 即使透明度为 0 也照样占位，标题会被挤得左右乱跳。
   */
  @Builder
  buildStickyBar(index: number) {
    Row({ space: 8 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.sectionIcons[index])
          .width(Const.DETAIL_STICKY_ICON)
          .height(Const.DETAIL_STICKY_ICON)
      }
      .width(Const.DETAIL_STICKY_ICON + 14)
      .height(Const.DETAIL_STICKY_ICON + 14)
      .borderRadius(Const.DETAIL_STICKY_RADIUS)
      .backgroundColor(Const.NIGHT_CARD_BG_LIGHT)

      Text(Const.DETAIL_SECTION_TITLES[index])
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Const.NIGHT_TEXT)

      Blank()

      Text(`${index + 1} / ${Const.DETAIL_SECTION_TITLES.length}`)
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
    }
    .width(Const.FULL_PERCENT)
    .height(Const.DETAIL_STICKY_HEIGHT)
    .padding({ left: Const.PAGE_MARGIN, right: Const.PAGE_MARGIN })
    .backgroundColor(Const.NIGHT_BG)
    .border({ width: { bottom: 1 }, color: Const.NIGHT_DIVIDER })
  }

  /**
   * 分区一：站点简介。
   */
  @Builder
  buildIntroSection() {
    Column({ space: 12 }) {
      Text(this.contentData.intro)
        .fontSize(14)
        .lineHeight(24)
        .fontColor(Const.NIGHT_TEXT)
        .width(Const.DETAIL_BODY_WIDTH)

      // 海拔 / 里程 / 爬升的现成文案（装配时算好，页面不拼字符串）。
      Text(this.contentData.metaText)
        .fontSize(12)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .width(Const.DETAIL_BODY_WIDTH)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Const.DETAIL_SECTION_GAP, bottom: Const.DETAIL_SECTION_GAP })
  }

  /**
   * 分区二：沿途影像（横向卡组，点当前那张看大图）。
   */
  @Builder
  buildPhotoSection() {
    Column({ space: 10 }) {
      SpotPhotoDeck({
        photos: this.contentData.photoList,
        names: this.contentData.photoNameList,
        seqs: this.contentData.photoSeqList,
        focusIndex: this.contentData.photoFocusIndex,
        onPreview: (index: number) => {
          this.previewIndex = index;
          this.showPreview = true;
        }
      })

      Text(Const.DETAIL_DECK_HINT)
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Const.DETAIL_SECTION_GAP, bottom: Const.DETAIL_SECTION_GAP })
  }

  /**
   * 分区三：夜爬提示（本站提示 + 数据口径与照片来源说明）。
   */
  @Builder
  buildTipSection() {
    Column({ space: 12 }) {
      // 提示正文用卡片包一层：与下面的数据口径 / 照片来源说明区分开
      // （那两行是「免责说明」，不能和提示本身混作一谈）。
      Text(this.contentData.tip)
        .fontSize(13)
        .lineHeight(21)
        .fontColor(Const.NIGHT_ACCENT)
        .width(Const.DETAIL_BODY_WIDTH)
        .padding(Const.CARD_PADDING)
        .borderRadius(Const.CARD_RADIUS)
        .backgroundColor(Const.NIGHT_CARD_BG)

      Text(Const.ZONES_DATA_NOTE)
        .fontSize(10)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .width(Const.DETAIL_BODY_WIDTH)

      Text(Const.SPOT_PHOTO_CREDIT)
        .fontSize(10)
        .fontColor(Const.NIGHT_TEXT_SUB)
        .width(Const.DETAIL_BODY_WIDTH)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Const.DETAIL_SECTION_GAP, bottom: Const.DETAIL_SECTION_GAP })
  }

  /**
   * 浮动按钮组：左上「返回」固定可见（导航必需），右下「回到首图」跟随滚动渐显。
   */
  @Builder
  buildFloatButtons() {
    Column() {
      Row() {
        this.buildBackButton()
        Blank()
      }
      .width(Const.FULL_PERCENT)

      Blank()

      Row() {
        Blank()
        this.buildTopButton()
      }
      .width(Const.FULL_PERCENT)
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .padding({
      left: Const.DETAIL_BAR_MARGIN,
      right: Const.DETAIL_BAR_MARGIN,
      top: Const.DETAIL_BAR_MARGIN,
      bottom: Const.DETAIL_BAR_MARGIN + Const.DETAIL_BAR_MARGIN / Const.DOUBLE_OR_HALF
    })
    // 这层只是给按钮定位用的，本身不能吃掉列表的滑动：交给子节点即可。
    .hitTestBehavior(HitTestMode.Transparent)
  }

  /**
   * 左上返回按钮。
   */
  @Builder
  buildBackButton() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.ic_hs_back'))
        .width(Const.DETAIL_BAR_ICON)
        .height(Const.DETAIL_BAR_ICON)
    }
    .width(Const.DETAIL_BAR_SIZE)
    .height(Const.DETAIL_BAR_SIZE)
    .borderRadius(Const.DETAIL_BAR_SIZE / Const.DOUBLE_OR_HALF)
    .backgroundColor(Const.DETAIL_BAR_BG)
    .border({ width: 1, color: Const.DETAIL_BAR_BORDER })
    .onClick(() => {
      // 与 openDetail 对称：走 UIContext.Router，不用已废弃的全局 router。
      this.getUIContext().getRouter().back();
    })
  }

  /**
   * 右下「回到首图」按钮：首图满屏时透明（此时页面就在首图，按钮没意义）。
   */
  @Builder
  buildTopButton() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.ic_hs_top'))
        .width(Const.DETAIL_BAR_ICON)
        .height(Const.DETAIL_BAR_ICON)
    }
    .width(Const.DETAIL_BAR_SIZE)
    .height(Const.DETAIL_BAR_SIZE)
    .borderRadius(Const.DETAIL_BAR_SIZE / Const.DOUBLE_OR_HALF)
    .backgroundColor(Const.DETAIL_BAR_BG)
    .border({ width: 1, color: Const.DETAIL_BAR_BORDER })
    .opacity(this.anim.topButtonOpacity)
    // 透明时不该还能点到，否则会在首图上误触。
    .hitTestBehavior(this.anim.topButtonOpacity > 0 ? HitTestMode.Default : HitTestMode.None)
    .onClick(() => {
      this.backToHero();
    })
  }

  /**
   * 全屏大图预览：整张图等比放下，点任意处关闭。
   */
  @Builder
  buildPreview() {
    Column({ space: 14 }) {
      Image(this.previewPhoto())
        .width(Const.FULL_PERCENT)
        .layoutWeight(1)
        .objectFit(ImageFit.Contain)
        .draggable(false)

      Text(this.previewLabel())
        .fontSize(13)
        .fontColor(Const.NIGHT_ACCENT)

      Text(Const.DETAIL_PREVIEW_CLOSE)
        .fontSize(11)
        .fontColor(Const.NIGHT_TEXT_SUB)
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .padding({
      left: Const.PAGE_MARGIN,
      right: Const.PAGE_MARGIN,
      top: Const.DETAIL_BAR_SIZE * Const.DOUBLE_OR_HALF,
      bottom: Const.DETAIL_BAR_SIZE * Const.DOUBLE_OR_HALF
    })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Const.DETAIL_PREVIEW_BG)
    .onClick(() => {
      this.showPreview = false;
    })
  }

  /**
   * 回到首图：列表滚回顶部，同时把首图高度与按钮透明度复位。
   *
   * 首图高度是我们自己的状态（不是由列表位移反推出来的），所以回顶时必须
   * 一并复位，否则列表到头了首图还是缩着的。两段动画时长取同一个常量，
   * 看起来才像「一起长回去」。
   */
  private backToHero(): void {
    this.anim.scrollerForList.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: { duration: Const.DETAIL_BACK_TOP_DURATION, curve: Curve.Linear }
    });
    this.getUIContext().animateTo({
      duration: Const.DETAIL_BACK_TOP_DURATION,
      curve: Curve.Linear
    }, () => {
      this.anim.heroPercent = Const.DETAIL_HERO_MAX_PERCENT;
      this.anim.topButtonOpacity = 0;
    });
  }

  /**
   * 进度条填充宽度：至少留一点点，免得前几站看起来像没画。
   */
  private progressWidth(): Length {
    const percent: number = Math.max(2, this.contentData.progress * Const.FULL_PERCENT_NUMBER);
    return `${Math.min(Const.FULL_PERCENT_NUMBER, percent)}%`;
  }

  /**
   * 首图上那一行补充信息：海拔与累计里程。
   */
  private buildHeroMeta(): string {
    return `${Const.DETAIL_LABEL_ALTITUDE} ${this.contentData.altitude}${Const.DETAIL_UNIT_ALTITUDE}`
      + ` · ${Const.DETAIL_LABEL_DISTANCE} ${this.contentData.distance}${Const.DETAIL_UNIT_DISTANCE}`;
  }

  /**
   * 预览用的照片：下标越界时收敛到最后一站，再不行回落到本站照片。
   */
  private previewPhoto(): Resource {
    const list: Resource[] = this.contentData.photoList;
    if (list.length === 0) {
      return this.contentData.photo;
    }
    const index: number = Math.max(0, Math.min(this.previewIndex, list.length - 1));
    return list[index];
  }

  /**
   * 预览图下方的标注：序号 + 站名。
   */
  private previewLabel(): string {
    const seqs: number[] = this.contentData.photoSeqList;
    const names: string[] = this.contentData.photoNameList;
    if (seqs.length === 0 || names.length === 0) {
      return this.contentData.title;
    }
    const index: number = Math.max(0, Math.min(this.previewIndex, seqs.length - 1));
    return `${seqs[index]} · ${names[index]}`;
  }
}
