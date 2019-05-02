(function (app) {
  'use strict';

  const API_VERSION = 'apiVersion'

  app.ports.getSavedApiVersion.subscribe(() => {
    const apiVersion = localStorage[API_VERSION]
    app.ports.retGetSavedApiVersion.send(apiVersion || '');
  });

  app.ports.saveApiVersion.subscribe(apiVersion => {
    localStorage[API_VERSION] = apiVersion;
    app.ports.completeSaveApiVersion.send(true);
  });

  const REGIONS = 'regions'

  app.ports.getSavedRegions.subscribe(() => {
    const regionsJson = localStorage[REGIONS];
    app.ports.retGetSavedRegions.send(regionsJson || '');
  });

  app.ports.saveRegions.subscribe(jsonResions => {
    localStorage[REGIONS] = jsonResions
    app.ports.completeSaveRegions.send(true);
  });

  const AREA_GARBAGE = 'area_garbage'

  app.ports.getSavedAreaGarbage.subscribe(areaNo => {
    const areaGarbage = localStorage[`${AREA_GARBAGE}-${areaNo}`]
    app.ports.retGetSavedAreaGarbage.send(areaGarbage || '');
  });

})(app)
