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

})(app)
