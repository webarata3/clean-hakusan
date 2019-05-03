(function (app) {
  'use strict';

  app.ports.loadLocalStorage.subscribe(key => {
    const loadData = localStorage[key];
    // 何を保存したかを表すkeyを返す
    app.ports.retLoadLocalStorage.send({ key: key, value: loadData || '' });
  });

  app.ports.saveLocalStorage.subscribe(object => {
    localStorage[object.key] = object.value;
    // 何を保存したかを表すkeyを返す
    app.ports.localStorageSaved.send(object.key);
  });

  app.ports.copyText.subscribe(() => {
    const elm = document.querySelector("#reason");
    const range = document.createRange();
    range.selectNode(elm);
    window.getSelection().addRange(range);
    document.execCommand('copy');
    alert('コピーしました。');
  });

})(app)
