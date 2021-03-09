 * 可以被拖的 Node:
   - draggable="true"
   - 提供的資料: ondragstart="event.dataTransfer.setData(mimetype,data)"
 * 接受東西拖進來的 Node ( 在 ondrop & ondragover 上 preventDefault, 以免開啟拖動物件 )
   - ondrop="event.dataTransfer.getData(mimetype);event.preventDefault()"
   - ondragover="event.preventDefault()"
 * 如果拖進來的東西是檔案
   - 在 ondrop 中檢查 event.dataTransfer.files 即可
 * 設定拖動時的樣貌
   - event.dataTransfer.dropEffect = <[copy move link]>[??]
 * 設定拖動時的 placeholder
    ghost = new Image!
    ghost.src = "data:image/svg+xml," + encodeURIComponent("""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="15" viewBox="0 0 20 15">
      <rect x="0" y="0" width="20" height="15" fill="rgba(0,0,0,.5)"/>
    </svg>
    """)
    e.dataTransfer.setDragImage(ghost,10,10)

