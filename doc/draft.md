# editable

實作 web-based DOM editing. 基本的文字輸入. 樣板式的元件插入. 樣式客製化、尺寸調整等等.

雜記

 - 使用 contenteditable 做基底: 一定還是得靠 contenteditable. 至少光輸入法我們就無法自己搞定了.
 - 提供 三個 Panel
   - Edit Panel: 就 WYSIWYG Panel
   - Layer Panel: 供可以快速得知我們選取的 tag
     - highlight div 時可由小標籤顯示 DOM 結構.
   - Config Panel
     - 用來做複雜進階設定.
     - config 其實平常不會常碰到, 代表這東西可以預設不顯示, 進階再觸發
     - config 面板, 非預設值的設定要 highlight, 方便用戶快查
 - 快速鍵與選單混搭
 - 編輯時, 標籤 highlight ( 邊框 / 背景色等 )
 - 區塊的尺寸調整需要有特定介面來設定
 - 避免畫面上過多的 bubble 跟 popup
 - 必須要認真考慮如何插入新元件 ( tag, block )
 - 空白元件 / 標籤需要 hint, 以避免出現找不到空白元件的問題


# 編輯上的需求

 - 混合 block 與 inline 的編輯要有良好體驗. 例如,
   - 按鈕前後打字不能莫名奇妙的進入或跑出按鈕. ( Well-Behaved Selections, in "Why ContentEditable is Terrible" )


# 值得一讀

 - How the Medium Editor Works / Why ContentEditable is Terrible
   https://medium.engineering/why-contenteditable-is-terrible-122d8a40e480

# 編輯器設計

 - 快速鍵與選單混搭
 - 編輯時, 標籤 highlight ( 邊框 / 背景色等 )
   - webflow 的設計不錯, highlight 上有元件名 tag, 點擊 tag 會列出所有父元件
 - 區塊的尺寸調整需要有特定介面來設定
 - 避免畫面上過多的 bubble 跟 popup
 - 必須要認真考慮如何插入新元件 ( tag, block )
 - 空白元件 / 標籤需要 hint, 以避免出現找不到空白元件的問題


# draft thought

 - 文字編輯靠 contenteditable.
   - 編輯時期 contenteditable 屬性不該進 serialized obj.
   - contenteditable 標籤內含子元件(亦可contenteditable)的話, 子元件預設 contenteditable=false
     - 這樣可以解決游標在標籤邊界時,文字不知道要插在前面或後面的問題.
     - 相對的若要編輯子元件, 就需要用滑鼠再點.
   - 但為了保持這個效果, 就必須讓所有可編輯的元件預設為不可編輯. 所以我們
     1. 需要識別可編輯元件 ( 如依靠 editable 屬性 )
     2. 任何元件在點擊時才切換成 contenteditable=true. 
     3. 切換 contenteditable 時, 所有 [editable] 子元素都要設定 contenteditable=false
   - 但是在點擊時才切換 contenteditable 的話
     - 因為在點擊時才切換, 切換後才有游標, 因此沒辦法靠瀏覽器取得游標位置.
       - 我們需要自行算出游標位置並自行設定.
     - 若點擊的標籤已設為 true, 不需要再設定一次, 亦不要自己設定游標位置. 因為自己算的跟電腦算的有落差, 會造成閃爍
       - 最好我們能算出跟電腦接近的結果, 才不會造成用戶認知上的差異.
   - contenteditable 標籤內容全部刪除時.. 元件會變形.
     - 需要有一個 placeholder 內容來撐住他
     - 子元件會需要額外為他設計刪除鈕嗎？
       - 在 div 最後的子元件, 若設定游標的程式沒寫好, 游標不容易移到他後面. 所以有刪除鈕的確更方便
   - 注意 editable 元素間的互動. 如下例:
     - div(editable)
         h1(editable)
         .inner ...
     - 在上例中, 我們若實作 hover highlight, `.inner` 不會單獨被 highlight, 而是會 highlight editable.
       用戶會覺得 h1 跟 .inner 是一體的, 能從 .inner 往回刪除到 h1 中.
       這種情況下, .inner 也加上 editable 就可以讓 highlight 分開表示, 避免混淆.
 - header 標籤的問題
   - header in contenteditable 可以設成 editable 可以避免混亂的編輯行為
     - 但是這樣就無法用方向鍵控制游標進出 header.
     - 或者我們可以另外針對 contenteditable 做方向鍵控制游標進出時的行為?
 - table / input 標籤即便是在 contenteditable 中, 也無法簡單刪除. 見 contenteditable/index.pug, 有相關 fix
   - 簡單的 test case:
    .p-4(contenteditable="true") #[| before]#[input.form-control]#[| after]
    .p-4(contenteditable="true") #[| before]#[input(contenteditable="false")]#[| after]
    .p-4(contenteditable="true") #[| before]#[table(contenteditable="false"): tr: td hi]#[| after]
   - table 在未設定 contenteditable="false" / input 為 inline 時, 則不會有這個問題
   - 跨瀏覽器的行為可能也會有所不同
   - 夾在另一個 contenteditable 中好像可行, 但會跟後方有沒有文字有關:
     - 從 after 前刪除可以:
       .p-4(contenteditable="true") #[div(contenteditable="false"): input.form-control]#[| after]
     - 從最後刪除不行:
       .p-4(contenteditable="true") #[div(contenteditable="false"): input.form-control]
     - 而且, 不只是 input/table, 任何 block div(contenteditable="false") 都不行.
       - inline-block 可以但是 caret 位置會很怪
 - 多個 contenteditable="false" 元件併排時, 刪除(backspace) 會一次往前全部刪除.
 

highlight - 滑鼠hover 時提示用戶目前 hover 區塊範圍. 可用來做進階功能
 - 編輯會影響 div bounding box, 所以 highlight 要嘛跟著更新, 不然就要自動隱藏
   - 更新方式: 1. watch, 2. polling
 - 如果整個框都是 contenteditable, 沒辦法點旁邊取消 focus.
 - 內容變化可能導致滑鼠雖然沒有動卻移到別的區塊上，導致重新hover. 即便如此, focus 仍然沒有換.
   - 應該要設計成在編輯模式下, 除非有動滑鼠不然不會重新 hover
     - touch device 怎辦?

transport ( deserialize -> serialize )
 - 速度是個問題. debounce 後體驗有好一些, 但 node 一多一樣很費時.

drag & drop
 - 可以拖動的話, 選取文字該怎麼辦呢?
 - 因為文件會動態更新, 節點可能都會被修改, 所以我們可能會有需要:
   - 想辦法保留節點
   - 重新初始化 drag and drop
 - 進 contenteditable 後, 拖動會變成選取. 點擊空白區域時 contenteditable 會保持, 但 caret 會消失, 
   這時用戶想拖動, 就會變成選取. 我們可以在點擊 blur 時取消所有 contenteditable
   - 當 contenteditable on 時, 我們也許可以設計一個特殊模式 ( 其它東西虛化? )
     來暗示用戶現在在編輯模式 ( 用戶比較不會想拖動他? )

cut hole with blending 
 - https://stackoverflow.com/questions/30732695/css3-blending-mode-between-different-html-elements
