(function (app) {
  'use strict';

  app.ports.operateLocalStorage.subscribe(object => {
    if (object.tag === 'load') {
      const loadData = localStorage[object.key];
      // 何を保存したかを表すkeyを返す
      app.ports.retOperateLocalStorage.send({ tag: 'load', key: object.key, value: loadData || '' });
    } else if (object.tag === 'save') {
      localStorage[object.key] = object.value;
      // 何を保存したかを表すkeyを返す
      app.ports.retOperateLocalStorage.send({ tag: 'save', key: object.key, value: '' });
    } else if (object.tag === 'clear') {
      localStorage.clear();
      app.ports.retOperateLocalStorage.send({ tag: 'clear', key: '', value: '' });
    }
  });

  // app.ports.copyText.subscribe(() => {
  //   const elm = document.querySelector("#reason");
  //   const range = document.createRange();
  //   range.selectNode(elm);
  //   window.getSelection().addRange(range);
  //   document.execCommand('copy');
  //   alert('コピーしました。');
  // });

})(app)
