## 3.2.3c — textured Minecraft hand

- Compare default idle model silhouette and sharp pixel texture to Minecraft; report screenshot if orientation differs.
- Walk/stop, jump/land, turn and click LMB: smooth motion and visual swing, no FTAP grab/line while mode enabled.
- Original Minecraft crosshair centered; E menu and its buttons still clickable. Disable mode: native grab/crosshair restored.
- Change world FOV 30/70/120: independent hand camera remains 70, hand shape/size unchanged.
- Check hand size, disable/unload, death/respawn. Approved HUD remains unchanged.

## 3.2.3b — reference hand

- Compare the hand to the supplied PNG: same silhouette and texture.
- Change FOV between 30 and 120: hand size/pose must stay unchanged.
- Check size, walking bob, disable/unload. Approved hotbar unchanged.

## 3.2.3a — hand reference follow-up

- Compare idle hand silhouette and visible faces against supplied reference.
- Check FOV 70/120: depth should remain proportional, no flattened hand.
- Verify walking bob and Hand size. HUD is unchanged and user-approved in 3.2.3.

## 3.2.3 — Minecraft checks

- Smaller arm, adjustable Hand size, original Steve texture.
- Original hotbar at bottom center; health hearts track damage/healing, hunger stays full.
- Third-person bind ignored while Minecraft enabled, restored on disable; E menu works.
- Check proportions and PNG loading live; simulations do not verify rendered 3D appearance.

# 3.2.2abcf — Minecraft: первая тестовая версия

1. Избранное → Minecraft: включить. Проверить руку Стива, покачивание при ходьбе, остановку покачивания стоя.
2. Хотбар:9 ячеек, первые8 пустые, в9-й алмазный меч. Клавиши1–9 меняют выделенную ячейку; меч пока только иконка.
3. Заранее включить третье лицо, затем Minecraft: третье лицо выключается. Попытки включить его кнопкой и биндом должны оставаться выключенными.
4. Меню игры на E открывается/закрывается обычным образом. Выключить Minecraft: рука/хотбар исчезают, третье лицо снова включается вручную и биндом.
5. Изменить покачивание/размер хотбара, перезапустить скрипт. Проверить сохранение, смерть/возрождение и полное закрытие скрипта.

Полностью визуальный режим с блоками и новые взаимодействия не добавлены. Симуляции пройдены; внешний вид проверяется в игре.

# 3.2.2abc — Избранное

- После главной страницы есть вкладка со звездой; на русском — «Избранное».
- Она открывается и пока пустая. Остальные разделы доступны, при запуске первой открывается главная.
- Compilation and navigation/Home/localization simulations passed; live UI confirmation pending.

# 3.2.2ac input display — pending user test

- Personalization: enable Keyboard and mouse (default off); check WASD/E/Space, both Shift/Ctrl sides.
- Check LMB/RMB/middle press and scroll both ways; smooth release, no stuck highlight after alt-tab.
- Drag by background, resize, change three colors/opacity; reload and verify exact saved layout.
- Disable/unload hides/removes panel; movement and mouse game actions continue normally.

# 3.2.2c removal check

- Custom texture editor/themes absent.
- Standard Roblox map materials, colors and classic palettes work.
- Existing profiles retain unrelated settings.

## 3.2.2b — полная замена кастомных текстур (ожидает проверки)

1. Графика → Поверхности карты → Кастомные текстуры. Выбрать новый набор и Применить. Сначала проверить Dreamcore Atrium, Rose Quartz Palace, Emerald Temple, Cyberpunk Station, Forest Sanctuary. Первый запуск материала скачивает его карты; старая поверхность остаётся до готовности.
2. Сравнить реальные рисунки и реакцию на свет при движении камеры: снег, скалы, древесина, мрамор, металл должны отличаться. Это уже внешние цвет/нормали/шероховатость, не удалённые квадраты. Если карты не загрузились — Повторить загрузку текстур; сообщить название набора/текстуры и ошибку.
3. Редактор: выбрать поверхность, другую текстуру из35, масштаб и цвет. Проверить переключение на стандартные материалы, отключение, сброс и перезапуск. Исходные рисунки/наклейки восстанавливаются. Не менять подтверждённые настройки остальных разделов ради этой проверки.

## 3.2.2a — 20 текстурных пресетов и редактор (ожидает проверки)

1. Графика → Поверхности карты → настройки: переключить Стандартные материалы / Кастомные текстуры. Старые8 палитр остались в первом режиме;20 новых тем — во втором. Виден только выбранный режим и выбранная поверхность.
2. В Кастомных текстурах выбрать тему и нажать Применить палитру карты. Проверить Dreamcore, Rainbow World, Rose Quartz, Cyberpunk, Frozen Palace и остальные по желанию. Должны отличаться рисунки, а не только цвета. Сообщить название, если изображение отсутствует или выглядит плохо.
3. Выбрать поверхность: сменить текстуру, масштаб, цвет/радугу; проверить превью и изменение на карте. При желании Своя картинка → ID изображения. Другие поверхности и классические настройки сохраняются отдельно.
4. Переключить режим обратно, выключить оформление и сделать сброс: исходные текстуры/наклейки возвращаются. После перезапуска/конфига настройки восстанавливаются. Реалистичная Terrain-вода отдельная; Minecraft в этом выпуске нет.

## 3.2.2 — пять улучшений (ожидает проверки пользователем)

1. FTAP → Линия → Расширенное оформление: включить и покрутить толщину, длину текстуры, изгиб, прозрачность. Включить пульсацию, проверить скорость/силу. Выключение расширенного режима возвращает игровую форму; чужие линии не меняются. Проверить после смерти.
2. Персонализация → Звуки: для выбранной категории выставить громкость и скорость, проверить в игре и при прослушивании. Отключить звук категории, изменить её громкость, включить обратно: звук остаётся выключенным до снятия отключения, затем возвращается с выбранной громкостью. Остановить прослушивание; перезагрузка/Unload убирает его.
3. Графика → Поверхности карты: выбрать и применить восемь палитр. Особенно Cyber Violet/Arctic/Sakura/Obsidian. Затем вручную изменить поверхность и сбросить. Небо и освещение не должны переключаться вместе с палитрой.
4. FTAP → Прицел: шесть пресетов с превью, цвет, размер и радуга. Проверить Custom image со старым ID, открытие/закрытие меню и смерть. После отключения возвращается игровой прицел.
5. Снег: обычные настройки и изменение цвета работают, не пропадает при игре. Фризы/FPS оценить на своём сервере: симуляция проверяет лишние записи/поиски, не измеряет FPS Roblox.
6. Перезапуск/конфиги: новые настройки сохранились, сброс/Unload возвращает обычную игру. Старое подтверждённое поведение не просим тестировать заново без отдельной причины.

## 3.2.1abcf — карта и звуковые пресеты (подтверждено пользователем 2026-11-06)

Пользователь подтвердил последнее обновление в целом. Пункты ниже сохранены как сценарии регрессии; отдельные результаты по каждому ассету и длительности сессии не сообщались.

1. Графика → Поверхности карты: включить, открыть настройки, выбрать Траву, поставить Neon/ForceField и свой цвет. Другие поверхности, персонажи и игрушки не должны меняться. Проверить песок, камень, снег, остальные реально присутствующие участки; сообщить тип, если не находится.
2. Цвет и материал независимы: выключить цвет — материал остаётся. Выбрать Исходный материал — цвет остаётся. Сброс/выключение возвращают карту. Океан здесь исходный из частей; реалистичная Terrain-вода остаётся отдельной функцией.
3. Персонализация → Свои игровые звуки: для каждой нужной категории выбрать пресет и нажать Прослушать. Если ассет недоступен, сообщить категорию/название. Громкость и обрезку при игровом событии проверить отдельно от предпрослушивания.
4. Свой ID → пресет → свой ID: настройки не теряются, категории независимы. Исходный/Очистить/выключить возвращает игровой звук. Проверить также два пресета в отдельной карточке звука чёрной дыры.
5. Звук захвата: свой захват должен звучать один раз, удержание не повторяет; отпустить/взять — новое срабатывание. Чужой захват не запускает свой эффект. Проверить после смерти.
6. Перезапуск/конфиг: выбранные поверхности, материалы, цвета, пресеты и ID восстановились. Unload убирает эффекты и прослушивание.

## 3.2.1abc — notifications, audio, Personalization (pending live check)

1. Personalization sidebar: toy collection + coin icon + mutes/blackhole sound present; original functions/config values retained, Settings still last.
2. Create mannequin: success notification only after it appears. Toggle line/camera/water/etc: short on/off notice. No sliders/startup notification flood. Settings → Action notifications disables success toasts.
3. Personalization → Custom game sounds: enable, open gear, choose category, paste permitted Roblox audio ID/link, commit by blur/Enter. Only selected category changes; footsteps/jump/death apply to own avatar, exact-name rule matches that sound name.
4. Different category retains its own audio ID. Clear selected/disable/unload restores native audio; mute volume still works independently. New toys/respawn keep enabled replacements.
5. Reload: replacement IDs, master switch and notification preference persist. Audio permission/accessibility must be verified with real assets in Roblox.

## 3.2.1bc — startup issue provisionally accepted (2026-11-05)

- User provisionally accepts the reported startup hair/custom-face disappearance as fixed. No separate exact replay steps claimed. Asset/API fallback may complete asynchronously.
- Other scenarios below remain independent follow-up checks, not inferred as tested.
- Wheel into first person and back: head hides near, full avatar returns far; Freecam retains genuine hair without gray/keyboard helpers.
- Death/reload and several minutes of play: appearance stays correct. If hair objects are actually deleted by the game, this scoped reference repair does not recreate them.

## 3.2.1ac — own Custom Line only (pending live check)

- Enable own texture/color/rainbow: your line changes, nearby other players keep their real game lines.
- Another player grabs you: their line still stays native. Change your line options while both are grabbing.
- Drop/regrab, respawn and reload: own styling recovers; disable restores native appearance. Report if your own line stops styling near other players (ambiguous standalone origin is deliberately skipped).

## 3.2.1ab — holding status (pending live check)

- Hold a toy while protection needs recovery: spawn stays deferred and does not interrupt the real grab.
- Drop/throw it: holding status clears; recovery resumes after the existing short grace without Restore protection button.
- Repeat drop/grab, item deletion and death: no permanent holding status.

## 3.2.1c — initial Omega (pending live check)

- Execute: first visible symbol already colored/rotating, no white glyph then replacement.
- Through interface-loading phase the same symbol rotates without disappearing/rebuilding; normal short fade into main menu.

## 3.2.1b — startup (pending live check)

1. Fresh execute: black background, white status/dots, Arcade rainbow title/underline and rotating menu Omega, thin progress bar.
2. No fixed multi-second wait; menu opens after readiness with short fade. Compare fresh/repeated startup duration and responsiveness.
3. Unload/reset immediately after menu appears: no leftover black screen or duplicate emblem. Saved settings and first Home tab remain intact.

## 3.2.1a — toy replacements (pending live check)

- E → Your Toys: Campfire2, Poison Mushroom3, Hot Sauce5, white Toilet6.
- Plane/helicopter/Boombox/basketball absent from custom27; Decoy22/pallet23/Blobman24 unchanged. Opening remains immediate.
- Updated fixed set loads with existing collection switch; no editor or reset needed.

## 3.2.1 — custom coin icon (pending live check)

1. FTAP → Game interface → Custom coin icon starts OFF. Enable: native gold coin becomes black ⟡ with thin smoothly cycling contour/glow, fits original top-right box.
2. Real coin number remains readable and updates normally; coin button still opens its native action. Store price icons unchanged.
3. Off/unload restores original coin; reloading retains chosen switch. No extra copies after deaths/menu recreation.

## 3.2.0 — fixed collection only (pending live check)

- Collection toggle works; no item/slot editor, catalogue or collection reset action remains.
- Native E menu retains current27-toy set, pallet23, smaller stars and immediate opening.
- Old autosave loads without editor keys; disable restores native order.

## 3.1.9 — four toy replacements (pending live check)

- Snowball10, Glass Box11, burger19, ladder20; no Katana/Kunai/TetracubeI/T in the custom27.
- FloatingIsland21/Decoy22/pallet23/Blobman24 retained; native opening stays instant.
- Saved set upgrades four slots without moving other selections.

## 3.1.8 — curated starter (pending user check)

1. Existing starter upgrades automatically; if an independently customized set remains, Restore starter collection loads the new layout.
2. Decoy22/pallet23/Blobman24, rocket14 directly above pallet, dark crystal13/Tetracube L15. Check ergonomics in native9-column menu.
3. FloatingIsland21/DiscoColorBall25/LightBall26/JukeboxBlue27. Only cake for food; only Acoustic Guitar/Trumpet/Ocarina for instruments; no couches/TetracubeO.
4. Reload retains the new arrangement;3.1.7 instant opening remains intact.

## 3.1.7 — collection performance (pending live check)

1. Repeatedly open/close E: set should already be ordered without delayed visible rearrangement. Exactly27 custom stars; pallet23.
2. Toggle native favorite stars: custom placement stays fixed while enabled. Script editor still changes it; disable restores native order.
3. Play with the native menu closed, then open editor, select slots/search/pages: assess freezes/frame drops versus3.1.6.
4. Reload previous profile: order retained with pallet moved26→23; editor has27 selectable positions and smaller stars.

## 3.1.6 — custom collection (pending live confirmation)

1. Enable Settings → Custom toy collection, open E → Your Toys: rocket1, dark crystal2, Tetracub L4, pallet26.
2. Open collection settings: click a numbered slot, then a catalogue preview; native menu changes without Assign. Search and catalogue arrows work.
3. Move an already assigned toy: original slots swap. Reopen E and reload script: saved order remains.
4. Stars use native lower-right bounds; ordinary spawn/favorite buttons work. Off/unload restores native order; Shop and destruction tabs unchanged.

## 3.1.5 — Your Toys redesign, pending live verification

- Enable Settings → Custom toy collection, open E → Your Toys.
- Feature parameters: select toy from searchable list, select position, Assign; no text input required.
- Rocket first, pallet26; inspect Tetracub L and other preferred aliases.
- Selected cards show black stars with animated colored outlines at native star location; click/spawn/favorite controls still work.
- Disable/unload restores positions and removes custom stars.
- If adapter still fails, inspect automatic local PrimeVisuals/ToyMenu-Diagnostics.json from Xeno workspace; do not request separate diagnostic execution.

## 3.1.4 — коллекция Your Toys (ожидает проверки в игре)

- Включить Настройки → Своя коллекция игрушек; открыть E → Your Toys.
- Ракета первая, кристалл/Blobman/Tetracub L вверху; стандартный паллет26-й, если карточек достаточно.
- Спавн обычными кнопками и игровые звёздочки работают. Повторное открытие E не сбрасывает порядок.
- ПКМ по переключателю: выбрать позицию/название, поставить игрушку; перезапуск скрипта сохраняет выбор.
- Отключение/Unload возвращает обычный порядок. Магазин/другие вкладки не меняются.
- Если видно сообщение открыть Your Toys, хотя он открыт, нужно уточнение реальной структуры GUI: симуляция её не доказывает.

## 3.1.2 — partial user acceptance (2026-11-03)

- Freecam RMB never teleports character, including exit/focus loss and while holding objects. Native throw still works.
- CONFIRMED by user: hair remains visible in third person and Freecam even after playing for some time.
- Pending separately: custom face; recovery when cosmetics are already hidden at script startup. No respawn/reload or exact duration inferred.
- Close wheel zoom still hides head/hair; zoom out restores them.
- No keyboard/gray torso overlay; repeat after death and reload.

## 3.1.0 — проверка видимости (ожидает проверки в игре)

- Третье лицо: тело, волосы и своё лицо после нескольких минут игры.
- Приблизить камеру колесом: голова/волосы скрыты; отдалить — видны.
- Freecam: захват, вращение возле себя, отпускание — тело/волосы/лицо остаются видимыми.
- Переключение Freecam → третье лицо → первое, смерть и повторный запуск.
- Клавиатура и серый блок не появляются.

# Prime Visuals — список нового и журнал проверки

Обновлён: 2026-11-02. Текущий код: **3.0.4**.

| ID | Новая проверка | Статус |
| --- | --- | --- |
| UI-247 | Freecam и её параметры находятся в Prime Vortex внутри Visuals; Spectate остался в Обзоре, поиск и конфиги сохранены | Компиляция/симуляции пройдены; новое расположение ожидает подтверждения |

## Приёмка Major Update3.0 — новая, не покрывается одобрением2.4.4

| ID | Что проверить | Статус |
| --- | --- | --- |
| M3-01 | Полноэкранная загрузка, плавный уход, открытие меню, отсутствие оставшегося overlay | Симуляция/компиляция; live ожидается |
| M3-02 | Все карточки разделов без верхних вкладок; главная прежняя, прокрутка/поиск/сворачивание | Симуляция/компиляция; live ожидается |
| M3-03 | Omega вращается/меняет цвет в header/HUD, заголовок читается и не перекрывает поиск | Симуляция/компиляция; live ожидается |
| M3-04 | Параметры выключенной функции, назначение keyboard/mouse, Escape/Backspace, конфликты и включение | Симуляция/компиляция; live ожидается |
| M3-05 | Бинды пусты по умолчанию, menu/Freecam назначаются; HUD/launcher всегда открывает меню | Симуляция/компиляция; live ожидается |
| M3-06 | Темы/цвета/шрифты/прозрачность и HUD показатели/положение; save/slot/import/cold restore | Симуляция/компиляция; live ожидается |
| M3-07 | Unload/re-execute/ошибка загрузки убирают новые GUI/input, прежние эффекты продолжают работать | Симуляция/компиляция; live ожидается |

## Новый фикс защиты2.4.6

| ID | Проверка | Статус |
| --- | --- | --- |
| AK-246 | Серия смертей/респавнов, перемещения/броски, восстановление toy после исчезновения/потери weld, ручная кнопка, выключение/unload; статус не застревает при готовом хитбоксе | Компиляция/симуляции пройдены; игровое подтверждение ожидается |

## Новое после общей приёмки2.4.4

| ID | Проверка | Статус |
| --- | --- | --- |
| HOME-245 | Полноразмерный профиль слева, феникс справа сверху, сессия под ним; общие края, подробности, без обрезания/прокрутки при текущем DPI | Подтверждено пользователем 2026-11-02 общим одобрением новой главной |

## Актуальный итог — общее подтверждение 2026-11-02

Пользователь явно поручил засчитать **все текущие разделы и функции проверенными и подтверждёнными**. Вся текущая сборка2.4.4 принята пользователем целиком: Home, View, Graphics, Character, ESP (только Players/Tools), FTAP, Settings, конфиги, локализация, интерфейс, выключение/сброс/unload и общая работа текущих функций.

Открытых пунктов пользовательского приёмочного списка на2.4.4 больше нет. Ниже сохранён исторический журнал: прежние статусы «не проверено»/«ожидается» для существующих функций перекрыты этим общим одобрением. Это не запись о проведении каждого отдельного сценария и не независимая техническая гарантия. Отдельные наблюдения, устройства, длительность, R6/R15 и конкретные режимы не выдумываются.

Удалённые Объекты/Предметы ESP, анимации и экспериментальная графика остаются **удалёнными**, не получают статус протестированных и не восстанавливаются. Задачи по будущему улучшению дизайна/физики могут появиться заново по просьбе пользователя. Новые изменения после2.4.4 требуют своего списка проверок.

Подробный текущий checkpoint: [Acceptance-2.4.4.md](Acceptance-2.4.4.md).

### Русский язык — 2.4.2

| ID | Проверка | Версия | Статус |
| --- | --- | --- | --- |
| UI-242 | Русский: Объекты/Инструменты в ESP, параметры и новые popup, статусы защиты; EN и обратно, перезапуск с сохранённым RU | 2.4.2 | Компиляция и симуляция пройдены; игровое подтверждение ожидается |

### Компактная главная — 2.4.1

| ID | Проверка | Версия | Статус |
| --- | --- | --- | --- |
| HOME-241 | Профиль/версия/феникс и сессия помещаются без прокрутки; нет слоганов/quick access; кнопка подробностей переключает6 основных и12 подробных метрик, RU/EN и DPI | 2.4.1 | Компиляция и mock-проверки; внешний вид ожидает подтверждения |

### Исчезновение аватара через несколько минут — 2.4.0

| ID | Проверка | Версия | Статус |
| --- | --- | --- | --- |
| CAM-240 | Без ресета играть5–10 минут с включённым третьим лицом, переходить колесом в первое/обратно: видим весь скин; при наклоне вблизи нет волос; отключение и unload | 2.4.0 | Компиляция и 360 циклов обычной/LTM прозрачности в модели пройдены; проверка в FTAP ожидается |

### Волосы при наклоне — 2.3.9

| ID | Проверка | Версия | Статус |
| --- | --- | --- | --- |
| CAM-239 | Колесом войти в первое лицо, смотреть вверх/вниз: волосы и голова не перекрывают обзор; отдалить: скин целиком видим; повторить, выключить/unload | 2.3.9 | Компиляция и mock-проверки пройдены; игровое подтверждение ожидается |

### Видимость третьего лица — 2.3.8

| ID | Проверка | Версия | Статус |
| --- | --- | --- | --- |
| CAM-238 | Включить третье лицо, колесом перейти в первое, играть несколько минут, отдалить обратно; повторить и проверить тело/аксессуары, смерть, отключение | 2.3.8 | Компиляция и симуляция 150 переключений пройдены; длительная игровая проверка ожидается |

### Новая главная — 2.3.7

| ID | Проверка | Версия | Статус |
| --- | --- | --- | --- |
| HOME-237 | Баннер/феникс/профиль/статистика не перекрываются, прокрутка и подробности работают, быстрые переходы открывают нужные категории, RU/EN подписи и DPI | 2.3.7 | Компиляция и mock-проверки; внешний вид требует подтверждения пользователя |

### Регрессия Freecam после броска — 2.3.6

| ID | Проверка | Версия | Статус |
| --- | --- | --- | --- |
| FC-236 | После броска другим игроком переход/возврат ПКМ перемещает видимое тело целиком; 5–10 повторов, выход и повторное включение | 2.3.6 | Компиляция и симуляция пройдены; пользовательская проверка ожидается, прежнее одобрение Freecam не покрывает этот фикс |

Это текущий список новых/улучшенных функций после большого переноса **2.1.3**, последующих исправлений и переделки интерфейса. Старые функции, которые не менялись, повторно не отправляются на проверку. Более ранние системы отмечены в отдельном разделе ниже. История выпусков: [CHANGELOG](../CHANGELOG.md); источники переноса: [Visual-Source-Audit](Visual-Source-Audit.md). Все 336 сохраняемых настроек перечислены отдельно: [Settings-Inventory](Settings-Inventory.md).

## Как вести список

- **Подтверждено** — пользователь явно одобрил функцию/раздел. Это пользовательское подтверждение, не собственный запуск ассистента в Roblox.
- **Не проверено** — отдельного подтверждения новой версии/нового параметра нет; успешная симуляция этот статус не меняет.
- **Баг** — воспроизведённая или сообщённая проблема. **Нужна доработка** — работает, но требуется изменить поведение/удобство.
- **Нужна повторная проверка** — подтверждённая функция изменилась. Сохранять прежнее подтверждение с версией, отдельно отмечать изменённые пункты.
- **Удалено** — отсутствует в текущем коде; не просить тестировать.
- У каждого нового пункта постоянный ID. При новом выпуске добавлять строки/параметры, фиксировать версию изменения, результат и краткий отзыв. Не закрывать целый раздел из-за подтверждения одной функции. Не превращать отсутствие замечаний в подтверждение.
- Проверка каждого нового эффекта: включение → изменение перечисленных параметров → выключение/возврат исходного состояния. Для устойчивых эффектов отдельно нужны смерть/респавн, повторное включение, конфиг и выгрузка. Эти проверки не считаются автоматически выполненными вместе с проверкой внешнего вида.

## View → Camera — полностью подтверждено пользователем

| ID | Новое / улучшенное, что входило в проверку | Последнее изменение | Статус / основание |
| --- | --- | --- | --- |
| CAM-01 | Третье лицо: видимый скин/аксессуары сразу и через время, после смертей | 2.1.6 | Подтверждено |
| CAM-02 | Поворот третьего лица без удержания ПКМ, обычная чувствительность после выхода | 2.1.7 | Подтверждено |
| CAM-03 | Distance применяется сразу; колесо 0.5–80, переход в первое лицо и назад | 2.2.0 | Подтверждено |
| CAM-04 | Camera noclip — камера сквозь стены | Существующая функция | Подтверждено явно 2026-10-28 |
| CAM-05 | Spectate: наблюдение, возврат камеры, взаимоисключение с Freecam | 2.1.3 | Подтверждено |
| CAM-06 | Spectate: новый список DisplayName (@Username), головы, обновление состава сервера | 2.2.1 | Подтверждено явно 2026-10-28 |
| CAM-07 | Freecam: свободный полёт/поворот, WASD/Space/Q, скорость 10–600, колесо, HUD | 2.2.1–2.2.9 | Подтверждено вместе с полным Freecam |
| CAM-08 | Freecam: повторное E, спавн, закрытие меню, возобновление полёта | 2.2.7 | Подтверждено явно; также полное одобрение |
| CAM-09 | Freecam: ПКМ перенос/возврат, смещение вбок ≥6 studs, ЛКМ отдельно | 2.2.8 | Подтверждено явно |
| CAM-10 | Freecam: ПКМ бросает удерживаемую цель без возврата; пустые руки — возврат | 2.2.9 | Подтверждено общим одобрением полного Freecam |
| CAM-11 | Freecam: обычные ники игроков, без новых ESP-картинок | 2.2.9 | Подтверждено общим одобрением полного Freecam |
| CAM-12 | Freecam: F4/выключение, восстановление движения/камеры/чувствительности, смерть/респавн | 2.2.9 | Подтверждено общим одобрением полного Freecam после списка из 8 пунктов |
| CAM-13 | Smooth camera | Удалена в 2.2.1 | Удалено по просьбе пользователя |

Старые FOV 30–120, отключение ragdoll blur и тело от первого лица подтверждены ранее; новых изменений для повторной проверки сейчас нет. История Freecam: [Freecam-Interaction](Freecam-Interaction.md).

## View → Sky

| ID | Новое / улучшенное | Версия | Статус |
| --- | --- | --- | --- |
| SKY-01 | Коллекция исходных 13 skybox: выбор и применение | 2.1.3 | Подтверждено пользователем до расширения |
| SKY-02 | Семь дополнительных наборов; три одобрены, четыре заменены | 2.2.1 → 2.3.0 | Подтверждено пользователем целиком на 2.3.0 |
| SKY-03 | Сброс коллекционного неба к исходному игровому | 2.1.3 | Подтверждено |
| SKY-04 | Свой Skybox ID/ссылка, Load без Enter, скрытие солнца/облаков и ручное возвращение | Существующие настройки | Подтверждено ранее явными отзывами |
| SKY-05 | Remove haze / убрать дымку: включение и возврат при выключении | Существующая настройка | Подтверждено пользователем 2026-10-28 после уточнения Remove haze / Clouds |
| SKY-06 | Show sun, Sun size, Time of day | Существующие настройки | Подтверждено ранее общим отзывом о View |
| SKY-07 | Reset time and sun — отдельная кнопка сброса времени/солнца, не Reset sky | Существующая настройка | Подтверждено пользователем 2026-10-28 после уточнения сброса / изменения ползунком |
| SKY-08 | Clouds: включение, Density, Cover, цвет/радуга | Существующие настройки | Ранее одобрены настройки облаков и общий пакет радуги; не новый живой тест 2.3.0 |

Для каждого нового неба проверить все шесть сторон, отсутствие пустых/неподгрузившихся граней, переход на другой набор и Reset. Старые ID/ссылка, Load без Enter, солнце/облака и ручные настройки одобрены раньше; повторно проверять их только при изменении.

| ID | Набор | Статус |
| --- | --- | --- |
| SKY-N01 | Blue Horizon | Подтверждено пользователем 2026-10-28 |
| SKY-N02 | Purple Nebula | Подтверждено пользователем 2026-10-28 |
| SKY-N03 | Rainbow Galaxy — замена Vaporwave в 2.3.0 | Подтверждено пользователем 2026-10-28 на 2.3.0; история замены сохранена |
| SKY-N04 | Pink Morning | Подтверждено пользователем 2026-10-28 |
| SKY-N05 | Purple Radiance — замена Lavender Gradient в 2.3.0 | Подтверждено пользователем 2026-10-28 на 2.3.0; история замены сохранена |
| SKY-N06 | Dark Matter — замена Rose Gradient в 2.3.0 | Подтверждено пользователем 2026-10-28 на 2.3.0; история замены сохранена |
| SKY-N07 | Milky Way — замена Golden Hour в 2.3.0 | Подтверждено пользователем 2026-10-28 на 2.3.0; история замены сохранена |

## Graphics — подтверждённые функции сохранены; эксперименты удалены в 2.3.3

Старые пользовательские шейдеры/частицы, Realistic Water и FPS boost одобрены ранее. Это не подтверждает новые сцены, снег и оформление океана.

| ID | Функция / параметры, которые проверить | Версия | Статус |
| --- | --- | --- | --- |
| GFX-01 | Pale Frost: собственная сцена, переключение и возврат исходной картинки | 2.1.3 | Подтверждено пользователем 2026-10-28 |
| GFX-02 | Dreamy Night: собственная сцена, переключение и возврат | 2.1.3 | Подтверждено пользователем 2026-10-28 |
| GFX-03 | Tokyowami: сцена со своим небом, переключение/возврат; нет двух конкурирующих Sky | 2.1.3 | Подтверждено пользователем 2026-10-28 |
| GFX-04 | Fullbright: яркость, время/туман/тени, выключение восстанавливает исходное | 2.1.3 | Подтверждено пользователем 2026-10-28 |
| GFX-05 | Совместимость сцен с ручными фильтрами и применением/сбросом skybox | 2.1.3 → 2.3.1 | Подтверждено пользователем, включая редактор 2.3.1 |
| GFX-06 | Layered snowfall: три слоя, Classic/Snowflake 1, цвет/радуга | 2.1.3 | Подтверждено пользователем целиком со снегопадом на 2.3.1 |
| GFX-07 | Снег: плотность, размер, скорость, ветер, площадь, высота; слежение за камерой/игроком | 2.1.3 | Подтверждено пользователем целиком со снегопадом на 2.3.1 |
| GFX-08 | Ocean appearance: Water/Ice/Neon/Glass/Slate/Basalt | 2.1.3 | Подтверждено пользователем 2026-10-28 |
| GFX-09 | Океан: Custom color, цвет/радуга, выключение/восстановление; Realistic Water настраивается отдельно | 2.1.3 | Подтверждено пользователем 2026-10-28; общая покраска разных видов воды не требуется |

## Lighting editor — полностью подтверждён пользователем на 2.3.1

Исходные три пресета остаются неизменными. Новый редактор и изменённый ручной режим получили отдельное общее одобрение пользователя после списка проверок 2.3.1. Сохранение своих вариантов — существующие пять слотов полных конфигов в Settings → Profiles; отдельного банка только освещения в этом выпуске нет.

| ID | Проверка | Статус |
| --- | --- | --- |
| LIT-01 | Кнопка Edit selected preset: выбранная сцена копируется в ручной режим; исходный пресет и Fullbright выключаются, открывается ручная панель | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-02 | Скопировать по очереди Pale Frost/Dreamy Night/Tokyowami: картинка сохраняет параметры, дальнейшие правки не меняют оригиналы | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-03 | Страницы Цвет/Свет/Воздух/Эффекты/Фокус, кнопка настроек, перевод, доступность всех контролов | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-04 | Цвет: яркость Lighting, экспозиция, новая яркость CC, контраст/насыщенность/тон и радуга | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-05 | Свет и туман: Environment controls, время/наклон солнца, Ambient/Outdoor, верхний/нижний оттенки, цвет/начало/конец тумана | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-06 | Тени/мягкость, diffuse/specular: живое изменение и восстановление при отключении Environment controls | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-07 | Атмосфера: отдельный переключатель, Density/Offset/Color/Decay/Glare/Haze, цвета/радуга, возврат исходной атмосферы | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-08 | Bloom: интенсивность/размер/порог; лучи: интенсивность/ширина; Blur | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-09 | DOF: отдельное включение, Focus distance/radius, Near/Far blur, выключение | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-10 | Replace game effects: скрывает игровые фильтры Lighting, выключение возвращает их состояние | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-11 | Reset filters и выключение ручного режима восстанавливают освещение, нет остаточных эффектов; скопированный Tokyowami sky сбрасывается отдельно Reset sky | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-12 | Автосохранение/холодный запуск, пять именованных слотов/импорт/экспорт, радуга с сохранением ручного цвета, reset/unload | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |
| LIT-13 | Совместимость с Remove haze: скрывает ручную атмосферу, при выключении возвращает; сброс редактора не отменяет независимую опцию дымки | Подтверждено пользователем целиком с разделом Lighting на 2.3.1 |

Новые 38 ключей (подписи/полный список — инвентарь настроек):

`lightAirColor`, `lightAirColorRainbow`, `lightAirDecay`, `lightAirDecayRainbow`, `lightAirDensity`, `lightAirGlare`, `lightAirHaze`, `lightAirOffset`, `lightAmbient`, `lightAmbientRainbow`, `lightAtmosphere`, `lightBloomSize`, `lightBloomThreshold`, `lightClock`, `lightColorBrightness`, `lightDepth`, `lightDiffuse`, `lightEnvironment`, `lightFarBlur`, `lightFocusDistance`, `lightFocusRadius`, `lightFogColor`, `lightFogColorRainbow`, `lightFogEnd`, `lightFogStart`, `lightLatitude`, `lightLower`, `lightLowerRainbow`, `lightNearBlur`, `lightOutdoor`, `lightOutdoorRainbow`, `lightRaySpread`, `lightReplaceEffects`, `lightShadows`, `lightSoftness`, `lightSpecular`, `lightUpper`, `lightUpperRainbow`.

## Graphics → Experimental — удалено в 2.3.3

Самостоятельная реализация имитации отражённого света и солнечных Beam-лучей; без исполнения сторонних скриптов и без заявления о RTX. Старое одобрение Graphics на 2.3.1 эти эффекты не покрывает. Старые проверки Character и остальных разделов остаются отложенными; пользователь отдельно разрешил эту экспериментальную разработку.

| ID | Что проверить | Статус |
| --- | --- | --- |
| XG-01 | Отражённый свет: сравнить вкл/выкл у освещённых стен/предметов, желательно днём и рядом с цветными поверхностями | Удалено по просьбе пользователя в 2.3.3; проверка отменена |
| XG-02 | Качество Low/Balanced/High/Ultra: заметность и FPS; лимиты 12/24/40/64 источника соответственно | Удалено по просьбе пользователя в 2.3.3; проверка отменена |
| XG-03 | Сила, радиус света, дальность расчёта; отсутствие залипших старых огней при движении/перемещении предмета | Удалено по просьбе пользователя в 2.3.3; проверка отменена |
| XG-04 | Учитывать источники света: около настоящих ламп, в том числе при отсутствии прямого солнца | Удалено по просьбе пользователя в 2.3.3; проверка отменена |
| XG-05 | Объёмные солнечные лучи: снаружи при солнце выше горизонта, ограничение длины препятствиями, отсутствие лучей ночью | Удалено по просьбе пользователя в 2.3.3; проверка отменена |
| XG-06 | Количество/длина/область/ширина/видимость лучей, цвет/плавная радуга | Удалено по просьбе пользователя в 2.3.3; проверка отменена |
| XG-07 | Сочетание обоих эффектов с существующими пресетами, ручным редактором, FPS boost и Freecam; нормальная частота кадров | Удалено по просьбе пользователя в 2.3.3; проверка отменена |
| XG-08 | Выключение, reset/unload без оставшегося света/лучей; повторный запуск/смерть/замена камеры; сохранение настроек | Удалено по просьбе пользователя в 2.3.3; проверка отменена |

Удалённые ключи (история, отсутствуют в текущем реестре): `giDistance`, `giEnabled`, `giLocalLights`, `giQuality`, `giRange`, `giStrength`, `shaftColor`, `shaftColorRainbow`, `shaftCount`, `shaftEnabled`, `shaftLength`, `shaftOpacity`, `shaftRadius`, `shaftWidth`.

## Character — старое одобрение не покрывает новые эффекты

| ID | Функция / параметры, которые проверить | Версия | Статус |
| --- | --- | --- | --- |
| CHR-01 | Self highlight: отдельный Highlight, цвет/радуга; независимо от старого Forcefield | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-02 | Body colors: Head/Torso/LeftArm/RightArm/LeftLeg/RightLeg, каждый цвет/радуга | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-03 | Body transparency: все шесть групп отдельно, R6/R15 по доступности | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-04 | Hide accessories и Hide face: отдельно, возврат при выключении | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-05 | Jump circle: появление при прыжке, Image, цвет/радуга, диаметр, время жизни | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-06 | Character trail: положение, lifetime, начальная прозрачность, цвет/радуга | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-07 | Trail gradient: начало/конец, переключение между градиентом и одноцветным режимом | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-08 | Disintegration dust: четыре слоя при смерти, без дублей, исчезновение эффекта | 2.1.3 | Подтверждено пользователем 2026-10-29 |
| CHR-09 | Custom animation: выбор каждого варианта ниже, speed 0.1–5, Stop animation, респавн | 2.1.3 | Удалено из Visuals 2.3.4; перенос в Vortex отложен |

Старые Forcefield/Cone hat одобрены раньше. У манекенов известно отличие ragdoll от физики FTAP: пользователь отложил доработку; не объявлять точным совпадением или исправленным.

### Отдельные варианты анимаций

Наличие ID в исходнике и прохождение симуляции не подтверждает доступность Animation для текущего персонажа. У недоступного варианта записывать конкретное имя и результат, не закрывать весь набор.

| ID | Вариант | Статус |
| --- | --- | --- |
| ANI-01 | Dance / Club | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-02 | Dance / Dab | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-03 | Dance / Groove | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-04 | Dance / Jump Dance | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-05 | Dance / Moon Dance | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-06 | Dance / Moving Dance | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-07 | Dance / Robot | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-08 | Dance / Shuffle | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-09 | Dance / Spin Dance | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-10 | Dance / Spin Dance 2 | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-11 | Dance / Spinner | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-12 | Dance / Thriller | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-13 | Emote / Arm Detach | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-14 | Emote / Arm Turbine | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-15 | Emote / Barrel Roll | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-16 | Emote / Bow Down | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-17 | Emote / Clone Illusion | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-18 | Emote / Crouch | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-19 | Emote / Dino Walk | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-20 | Emote / Faint | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-21 | Emote / Float Sit | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-22 | Emote / Floating Head | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-23 | Emote / Floor Crawl | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-24 | Emote / Floor Faint | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-25 | Emote / Full Punch | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-26 | Emote / Full Swing | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-27 | Emote / Glitch Levitate | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-28 | Emote / Head Throw | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-29 | Emote / Hero Jump | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-30 | Emote / Insane | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-31 | Emote / Insane Arms | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-32 | Emote / Jumping Jacks | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-33 | Emote / Levitate | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-34 | Emote / Loop Head | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-35 | Emote / Loop Slam | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-36 | Emote / Mega Insane | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-37 | Emote / Scared | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-38 | Emote / Super Faint | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-39 | Emote / Super Punch | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-40 | Emote / Sword Slam | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-41 | Emote / Sword Slice | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-42 | Emote / Weird Move | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-43 | FTAP / Crouch | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-44 | FTAP / Fire Flail | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-45 | FTAP / Flail | Удалено из Visuals 2.3.4; перенос в Vortex отложен |
| ANI-46 | FTAP / Type | Удалено из Visuals 2.3.4; перенос в Vortex отложен |

## ESP — новые/расширенные возможности

Старая подсветка, выбор игроков, никнеймы без голов в мире и старые объекты подтверждены ранее. Новые виды отображения ниже этим не покрываются.

| ID | Функция / параметры, которые проверить | Версия | Статус |
| --- | --- | --- | --- |
| ESP-01 | Box ESP: рамка, цвет/радуга, толщина, дальность, выбранные/все игроки, цель за камерой | 2.1.3 | Подтверждено пользователем 2026-11-02 по10 пунктам ESP игроков; R6/R15 по отдельности не уточнялись |
| ESP-02 | Skeleton ESP: связи R6/R15, цвет/радуга, толщина; независимость от Box/Highlight | 2.1.3 | Подтверждено пользователем 2026-11-02 по10 пунктам ESP игроков; R6/R15 по отдельности не уточнялись |
| ESP-03 | Players ESP: HP, дистанция в studs, максимальная дальность | 2.1.3 | Подтверждено пользователем 2026-11-02 по10 пунктам ESP игроков; R6/R15 по отдельности не уточнялись |
| ESP-04 | Подписи ESP: фон, дополнительные Rounded/Gotham/Arcade/Source шрифты; старые настройки текста сохранены | 2.1.3 | Подтверждено пользователем 2026-11-02 по10 пунктам ESP игроков; R6/R15 по отдельности не уточнялись |
| ESP-05 | Server detectors/PCLD: PartESP, вложенные детекторы, ограничение дальности; старая плавность/рамка | 2.1.3 | Удалено по просьбе пользователя в2.4.4; прежнее одобрение историческое |
| ESP-06 | Blobman / Gucci ESP: обе категории, цвет/радуга, удаление объекта | 2.1.3 | Удалено по просьбе пользователя в2.4.4; прежнее одобрение историческое |
| ESP-07 | Anti-kick objects ESP: Shuriken/Kunai/Plate/Pickaxe/Pallet; цвет/радуга, fill, Other players only | 2.1.3 | Удалено по просьбе пользователя в2.4.4; прежнее одобрение историческое |
| ESP-08 | Combat items ESP: Banana/Snowball/Shuriken/Kunai/Pickaxe, каждый переключатель, peel не считается Banana | 2.1.3 | Удалено по просьбе пользователя в2.4.4; прежнее одобрение историческое |
| ESP-09 | Combat items: иконки, размер, подписи, цвет/радуга, fill; нет дублей Model/дочерних частей | 2.1.3 | Удалено по просьбе пользователя в2.4.4; прежнее одобрение историческое |
| ESP-10 | Reveal invisible characters: локальное раскрытие доступных клиенту частей и восстановление | 2.1.3 | Не проверено |
| ESP-11 | Trace to player: точный username, линия/пульсация, цвет/радуга, потеря цели | 2.1.3 | Не проверено |
| ESP-12 | Target marker: включение, размер, Image, вращение, скрытие при отсутствии цели | 2.1.3 | Не проверено |
| ESP-13 | Estimated server position: клиентская история/след, цвет, затухание при остановке; это оценка, не серверное измерение | 2.1.3 | Не проверено |

## FTAP — новые дополнения

| ID | Функция / параметры, которые проверить | Версия | Статус |
| --- | --- | --- | --- |
| FTP-01 | Custom line: Gradient, независимые начало/конец и переключение обратно на цвет/радугу | 2.1.3 | Не проверено |
| FTP-02 | Animated blackhole image: появление, вращение, рост/исчезновение | 2.1.3 | Не проверено |
| FTP-03 | Blackhole animation: Image, цвет/радуга, размер, прозрачность | 2.1.3 | Не проверено |
| FTP-04 | Hide original visual и Hide at map origin: отдельно, восстановление | 2.1.3 | Не проверено |

Старая линия/одноцветная радуга, её восстановление после смертей, прицел/радуга и отключение звуков подтверждены раньше. Старые пункты чёрных дыр пользователь разрешил засчитать без личного теста — это историческое одобрение, не наблюдённый тест и не одобрение новой анимации.

## Интерфейс и общая устойчивость после большого обновления

| ID | Изменение / проверка | Версия | Статус |
| --- | --- | --- | --- |
| UI-01 | Подстраницы всех категорий, объединённые карточки, переключение без изменения функций | 2.1.4 | Не проверено отдельно после исправления кликов |
| UI-02 | Кнопка параметров и ПКМ, закреплённая панель, закрытие снаружи/Escape/сменой страницы/выключением функции | 2.1.4–2.1.5 | Не проверено отдельно |
| UI-03 | Dropdown/палитра внутри панели не закрывают её; General/Appearance в сложных ESP | 2.1.4–2.1.5 | Не проверено отдельно |
| UI-04 | Русские подписи/подсказки, поиск по скрытым подстраницам и кириллице, пустой результат | 2.1.4 | Не проверено отдельно |
| UI-05 | Реальные клики переключателей/кнопок, ввод слайдера/перетаскивание; поля принимают blur/Enter, Escape отменяет | 2.1.5 | Не проверено систематически; рабочие функции камеры не доказывают все контролы |
| SYS-01 | Все новые параметры: автосохранение, холодный запуск, слоты, импорт/экспорт | 2.1.3+ | Не проверено для полного нового пакета; базовые конфиги одобрены ранее |
| SYS-02 | Все новые эффекты: reset/unload без остаточных объектов/настроек; возврат исходного состояния | 2.1.3+ | Не проверено для полного нового пакета |
| SYS-03 | Новые длительные эффекты: многократные смерти, замена камеры/GUI, повторный запуск, отсутствие дублей/заметных лагов | 2.1.3+ | Не проверено для полного нового пакета; Freecam отдельно подтверждён |

## Более ранние изменения и отдельные ограничения

| ID | Система | Статус / что не забыть |
| --- | --- | --- |
| BASE-01 | Major Update 2.0: автосохранение, пять слотов, названия, импорт/экспорт/удаление/восстановление | Подтверждено пользователем целиком; новые параметры проверять по SYS-01 |
| BASE-02 | Home: профиль/статистика, иллюстрация, компактный значок, старт всегда с Home | Подтверждено ранее; версия UI после 2.1.4 не имеет отдельного полного подтверждения |
| BASE-03 | Устойчивость запуска/цветового виджета/PrimeIcon и менеджер Custom line | Исправлено и проверялось в симуляциях; старое восстановление линии одобрено пользователем, отказные сценарии не считать лично проверенными |
| BASE-04 | Anti-Kick 2.1.8: вкл/выкл, собственный предмет/привязка, смерть/восстановление, пауза на чужом участке, очистка | Только один сообщённый успешный случай защиты от Blobman; полный список поведения отдельно не подтверждён |
| BASE-05 | Anti-Kick 2.1.9: локальное скрытие защитного сюрикена/поздних деталей с сохранением привязки | Нет отдельного явного подтверждения скрытия |
| BASE-06 | Манекены/аватар по имени и ragdoll | Базовый спавн обсуждался/работал; улучшение соответствия физике FTAP отложено пользователем. Не включать в подтверждение Camera |
| BASE-07 | Prime Vortex | Отдельная UI-оболочка; вне текущей проверки Visuals |

## Следующие шаги сверки

1. View (Camera + Sky) полностью подтверждён, включая отдельно уточнённые SKY-05/SKY-07. Lighting GFX-01…GFX-05 также подтверждён; снег GFX-06/GFX-07 также подтверждён; следующий пакет — оформление океана GFX-08/GFX-09.
2. Graphics: GFX-01…GFX-09.
3. Character и все 46 вариантов анимаций.
4. Новые ESP, FTAP; затем UI/профили/устойчивость для нового пакета.
5. После каждого ответа переносить результат к конкретному ID; если ответ обобщённый, сохранять пометку «одобрено разделом», не придумывать подробности теста.

В текущей переписке открытых новых багов Camera нет. Все остальные строки «Не проверено» означают отсутствие подтверждения, а не установленную неисправность.

### Отзыв о небе — 2026-10-28

Blue Horizon, Purple Nebula, Pink Morning понравились и явно одобрены. Vaporwave, Lavender Gradient, Rose Gradient, Golden Hour загрузились, но отклонены по внешнему виду, а не как технически нерабочие. В 2.3.0 заменены на Rainbow Galaxy, Purple Radiance, Dark Matter, Milky Way соответственно. Новые четыре не считать одобренными до следующего ответа. Новый Reset после этих замен также стоит проверить; его прежнее подтверждение сохраняется.

### Подтверждение замен — 2026-10-28

После списка четырёх замен и проверки граней/сброса пользователь ответил: «все так оставляем все подтверждаю». Все семь добавлений с учётом замен и текущая коллекция засчитаны одобренными на 2.3.0. Пользователь уточнил: это подтверждение только коллекции, не всего Sky, сброса или View целиком. Это пользовательское одобрение, без выдуманных подробностей по каждой грани. Следующий неподтверждённый пакет — новые возможности Graphics. Код не менялся.

### Уточнение области подтверждения — 2026-10-28

Пользователь уточнил: «я именно подтвердил коллекция неба только». Последнее одобрение относится только к коллекции и четырём заменам. Camera остаётся подтверждённой предыдущими ответами. Остальные настройки Sky и новый тест Reset этим ответом не подтверждены; прежние одобрения сброса/ручных настроек сохранены отдельно и не отменяются. Не объявлять весь View заново проверенным на основании этого ответа.

### Полнота View — сверка с кодом 2026-10-28

После повторного вопроса пользователя обнаружены два невыделенных в прежнем списке контрола: Remove haze и отдельная Reset time and sun. У них нет индивидуального явного одобрения; общий прошлый отзыв не считать доказательством нажатия именно этих контролов. Добавлены SKY-05/SKY-07. Пока они не подтверждены, не закрывать весь View. Остальные старые настройки Sky записаны явно, чтобы не терять их за строкой коллекции.

### Окончательное подтверждение View — 2026-10-28

После прямого уточнения различий Remove haze/Clouds и Reset time and sun/ползунка пользователь явно подтвердил, что выполнил именно предложенные действия. SKY-05 и SKY-07 закрыты. Теперь весь View (Camera + Sky) подтверждён по совокупности отдельных ответов. Следующий список проверки — GFX-01…GFX-05; остальные Graphics не закрывать без ответа. Ранее записанный пробел проверки устранён этим подтверждением.

### Lighting — отзыв пользователя 2026-10-28

GFX-01…GFX-05 подтверждены явно: все три пресета очень понравились; Fullbright проверен отдельно и совместно с пресетами; совместимость с фильтрами/небом без остаточного размытия или испорченных цветов одобрена. Это не подтверждает ещё не проверенные снег и оформление океана.

Пожелание к будущей доработке: больше выразительных пресетов и ручной доступ к дополнительным параметрам такого же уровня. Сверено с кодом: ручной Shaders сейчас имеет Brightness/Exposure/Saturation/Contrast/Tint, интенсивности Bloom/SunRays и Blur. У пресетов дополнительно используются Atmosphere Density/Offset/Color/Decay/Glare/Haze, Ambient/OutdoorAmbient, FogColor/Start/End, ColorShift, тени/мягкость, отражённый свет, CC Brightness, Bloom Size/Threshold, SunRays Spread и DepthOfField. Отмечено как пожелание, пока не реализовано и не включается в подтверждение существующих настроек. Не подменять желание новыми названиями с одинаковыми параметрами.

### Новый порядок проверки после 2.3.1

Пользователь выбрал сначала добавить редактор и расширенные параметры ручного света. Теперь следующий пакет — LIT-01…LIT-13 (редактор), затем непроверенные снег и океан. Прежние одобрения Camera/коллекции/трёх оригинальных пресетов сохранены; новое редактирование не засчитывать без ответа.

### Полное одобрение Lighting 2.3.1 — 2026-10-28

После списка проверок редактора пользователь явно подтвердил весь пункт «Освещение». GFX-01…GFX-05 и LIT-01…LIT-13 засчитаны по общему одобрению раздела, без выдуманных отдельных наблюдений по каждому ползунку. Следующий пакет — Graphics → Weather, новый снег GFX-06/GFX-07; затем оформление океана GFX-08/GFX-09. Старые частицы одобрены раньше. Не распространять одобрение Lighting на остальные подстраницы Graphics. Runtime остаётся 2.3.1, код не менялся.

### Снег подтверждён — 2026-10-28

Пользователь сначала сообщил об отсутствии снега, затем отменил сообщение, предположив долгий спуск, и окончательно уточнил: задержки нет, снег подтверждает целиком. GFX-06/GFX-07 приняты общим одобрением после списка из шести проверок. Первые сообщения не оставлять открытым багом или требованием ускорить снег. Код снегопада не менялся. Старые частицы были одобрены ранее; следующий неподтверждённый пакет — оформление океана GFX-08/GFX-09 в Water & FPS. Снег не подтверждает остальные неподтверждённые эффекты.

### Океан и закрытие Graphics — 2026-10-28

Пользователь отдельно подтвердил: все материалы меняются, Custom color работает и возвращается при выключении, радуга плавная, выключение функции восстанавливает исходные материал/цвет. Пятый пункт принят с уточнением области: оформление исходного океана и Realistic Water работают с разными представлениями воды и имеют отдельные настройки цвета. Не требовать, чтобы материалы океана перекрашивали Terrain Water, и не считать это багом.

GFX-08/GFX-09 закрыты. В совокупности с прежними одобрениями Lighting/редактора, снегопада, старых частиц, Realistic Water и FPS boost раздел Graphics подтверждён целиком на 2.3.1. Никакой код не менялся. Следующий неподтверждённый раздел — Character; старые Forcefield/Cone hat не отправлять заново, новые пункты CHR-01…CHR-09 и ANI-01…ANI-46 остаются отдельными.

### Проверки отложены пользователем — 2026-10-28

Пользователь попросил оставить проверку остальных функций на немного позже. View и Graphics сохраняют подтверждённый статус. Следующая точка продолжения — новые/улучшенные функции Character (CHR-01…CHR-09 и варианты ANI), затем оставшиеся ESP/FTAP/UI/системные пункты по журналу. Отложенные пункты не считать подтверждёнными. Не запускать новые проверки или изменения автоматически; ждать следующего запроса. Runtime остаётся 2.3.1.

### Экспериментальная графика 2.3.2

По отдельному запросу пользователя добавлены XG-01…XG-08. Следующее целевое испытание — эти новые эффекты в Graphics → Experimental; старые одобренные функции сохраняют статус, а остальные отложенные тесты не возобновляются автоматически. Сильное улучшение картинки/FPS в реальном FTAP ещё не установлено.

### Эксперименты удалены — 2026-10-28, 2.3.3

По прямой просьбе пользователя полностью удалены подстраница Experimental, обе функции, их модуль/обработчики и 14 настроек. XG-01…XG-08 закрыты как удалённые, а не подтверждённые. Старые конфиги не сбрасываются: неизвестные ключи игнорируются, одобренные параметры освещения сохраняются. Графика вернулась к трём прежним подстраницам. Остальные отложенные проверки не возобновлять автоматически.

### Character — подтверждение 2026-10-29

Пользователь отдельно подтвердил пункты CHR-01…CHR-08; круг при прыжке отметил как чёткий и плавный. CHR-09 и все ANI-01…ANI-46 пока не подтверждены. Вопрос о видимости анимаций другим игрокам не является результатом теста: код использует существующий Animator персонажа, а при его отсутствии создаёт локальный; репликация зависит от происхождения Animator и доступности анимации. Наблюдение со второго клиента ещё не выполнено. Runtime остаётся 2.3.3.

### Анимации убраны — 2026-10-29, 2.3.4

По просьбе пользователя удалены карточка анимаций, обработчики воспроизведения, 46 определений и три настройки. В Vortex пока не перенесены. CHR-01…CHR-08 остаются подтверждёнными. Старые ключи конфигов игнорируются.

### Персонаж полностью подтверждён — 2026-10-29

Пользователь явно попросил засчитать Character целиком подтверждённым в текущей версии 2.3.4. Раздел принят по общему пользовательскому подтверждению вместе с ранее одобренными эффектами; новые CHR-01…CHR-08 подтверждены отдельно. Удалённые CHR-09/ANI не входят в текущий раздел и не считаются протестированными. Ранее отложенное улучшение соответствия физики манекенов физике FTAP остаётся пожеланием, не открытым блокирующим багом. Следующая проверка — новые/улучшенные ESP. Код не менялся.

### Переделка UI — 2.3.5, 2026-10-29

Игровые функции и их прежние одобрения сохранены. Новая подача интерфейса требует отдельного пользовательского теста.

| ID | Проверить | Версия | Статус |
| --- | --- | --- | --- |
| UI-06 | Панели параметров через ПКМ/шестерёнку: перетаскивание за заголовок поверх основного меню, края экрана, запоминание положения после закрытия/перезапуска | 2.3.5 | Подтверждено пользователем 2026-10-29, общим одобрением UI |
| UI-07 | В плавающей панели работают кнопки/ползунки/ввод/палитры/dropdown; клик внутри не закрывает, снаружи/Escape закрывает; закрытие владельца/выгрузка очищает | 2.3.5 | Подтверждено пользователем 2026-10-29, общим одобрением UI |
| UI-08 | Новые верхние вкладки во всех разделах: иконки, русский/английский текст, плавный индикатор, наведение, быстрые переключения и поиск без ложных нажатий/обрезки | 2.3.5 | Подтверждено пользователем 2026-10-29, общим одобрением UI |
| UI-09 | Плавное появление при запуске/открытии без загрузочного экрана, быстрое повторное скрытие/открытие, нормальный курсор и отсутствие заметных лагов | 2.3.5 | Подтверждено пользователем 2026-10-29, общим одобрением UI |

### Подтверждение UI 2.3.5 — 2026-10-29

После списка проверки перемещения/сохранения положения панелей, внутренних контролов и новых вкладок/плавного открытия пользователь одобрил обновление целиком. UI-06…UI-09 приняты общим пользовательским подтверждением без выдуманных отдельных наблюдений. Это не закрывает новые ESP/FTAP и остальные непроверенные системные сценарии. Следующий раздел — новые/улучшенные ESP. Код и версия не менялись.

### ESP игроков — подтверждение 2026-11-02

Пользователь подтвердил все10 выданных проверок: рамки, скелет, независимость от highlight, HP/дистанция, дальность, фон/шрифты, выбор двух игроков, отсутствие артефактов за камерой, респавн и полная очистка при отключении. ESP-01…04 приняты на текущем runtime2.4.2. Не переносить подтверждение на объекты, tools или Reveal invisible. Следующий пакет: ESP → Объекты, ESP-05…09. Код и версия не изменены.

### Единое меню предметов2.4.3

| ID | Проверка | Статус |
| --- | --- | --- |
| OBJ-243 | ESP/Предметы: master, страницы Типы/Оформление/Цвета, раздельные типы, дальность, подписи/иконки/заливка, цвет/радуга, off/on и старые профили | Удалено по просьбе пользователя в2.4.4; прежнее одобрение историческое |

### Удаление вкладок ESP — 2026-11-02

Объекты/Предметы удалены полностью по явному запросу, включая все их настройки и исполнение. ESP игроков подтверждён ранее; следующий пакет — Инструменты ESP-10…13. Удалённые функции не возвращать для тестирования. Runtime2.4.4; 257 ключей.

### HUD3.0.2

HUD-302: компактность/скругление, drag мышью/касанием, перезапуск с точнымX/Y, без открытия меню после drag. Симуляции пройдены, игровая проверка ожидается.

### AV-303 — волосы/лицо и Freecam

После игры несколько минут без ресета: третье лицо показывает волосы/обычный скин; Freecam показывает стоящего персонажа; в первом лице голова скрыта; повторить переключения и unload. Симуляции пройдены, живое подтверждение ожидается.

### UI-304 — надпись и компактная панель

Arcade-надпись с фиксированными цветами букв и радужной линией совпадает по стилю в шапке/HUD; нет перекрытия поиска; Omega крупнее; FPS рядом с текстом, drag/позиция сохранены. Автоматические проверки пройдены, визуальная оценка ожидается.
