 - test case
   - 為了長期開發, 應該將必要的測試逐項紀錄, 方便後期重頭驗證
     - 最好還可以自動化

 - resize
   - support following
     - flex (parent)
     - grid (parent)
     - inline-block
     - block
   - algorithm
     - inline-block: update self
     - block: ?
     - flex
       - direction (row,column,reverse)
       - flex-wrap
         - nowrap: should update neighbor
         - warp: update self
   - advanced function
     - preserve aspect ratio ( when resizing )
     - clear all settings
     - use px(absolute) / %(relative) / em( relative to font-size )
        

 - block tree group / ungroup mechanism
 - inline style editing and toolbar
 - inline function ( clone, delete, etc )
 - DOM hierarchy tip
 - attribute editor
 - serializer / deserializer
 - config panel
 - layer panel
 - popup
   - insert
   - align
   - backgorund settings
   - clone / delete ?
   - styling
   - attr value

done
 - drag for both block / inline type
