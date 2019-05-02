(function (app) {
  'use strict';

  app.ports.getSavedApiVersion.subscribe(() => {
    const apiVersion = localStorage['apiVersion']
    app.ports.retGetSavedApiVersion.send(apiVersion || '');
  });

})(app)
