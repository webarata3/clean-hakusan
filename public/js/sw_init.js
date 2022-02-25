if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    navigator.serviceWorker.register('/service-worker.js').then(() => {
      // console.log('登録成功');
    }, () => {
      // console.log('登録失敗');
    });
  });
}
