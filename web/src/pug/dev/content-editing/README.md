 - 雙層結構:

    div(editable)
      .inline-block(editable) hi
   
   遊標在最後面時, 仍然會顯示在 .inline-block 中

 - inline-block 並列且有內容時, 想新插入 div, 沒辦法插入其中, 而會進到 div 中
   - 若沒內容, 遊標用鍵盤移動時, 在 div 前後看起來會一樣, 變成要打兩下
